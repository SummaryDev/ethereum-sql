import * as fs from 'fs';
import * as path from 'path';
import {stringify} from 'csv';

export const supportedTypesDict = {
  'address': {'function': 'to_address', 'args': [], 'type': 'text'},
  'uint256': {'function': 'to_uint256', 'args': [], 'type': 'decimal'},
  'address[]': {'function': 'to_array', 'args': ['\'address\''], 'type': 'text'}, // todo what should be the result column type of arrays? not text but super or array?
  'uint256[]': {'function': 'to_array', 'args': ['\'to_uint256\''], 'type': 'text'},
  'string[]': {'function': 'to_array', 'args': ['\'string\''], 'type': 'text'},
  'bytes[]': {'function': 'to_array', 'args': ['\'bytes\''], 'type': 'text'},
  'bool[]': {'function': 'to_array', 'args': ['\'bool\''], 'type': 'text'},
  'bytes32': {'function': 'to_fixed_bytes', 'args': [32], 'type': 'text'},
  'bool': {'function': 'to_bool', 'args': [], 'type': 'bool'},
  'string': {'function': 'to_string', 'args': [], 'type': 'text'},
  'bytes': {'function': 'to_bytes', 'args': [], 'type': 'text'},
  'uint128': {'function': 'to_uint128', 'args': [], 'type': 'decimal'},
  'uint64': {'function': 'to_uint64', 'args': [], 'type': 'decimal'},
  'bytes4': {'function': 'to_fixed_bytes', 'args': [4], 'type': 'text'},
  'uint32': {'function': 'to_uint32', 'args': [], 'type': 'decimal'},
  'uint16': {'function': 'to_uint32', 'args': [], 'type': 'decimal'}, // todo create to_uint16 instead of reusing to_uint32
  'uint8': {'function': 'to_uint32', 'args': [], 'type': 'decimal'},
  'bytes16': {'function': 'to_fixed_bytes', 'args': [16], 'type': 'text'},
  'uint256[3]': {'function': 'to_fixed_array', 'args': ['\'to_uint256\'', 3], 'type': 'text'},
  'uint256[2]': {'function': 'to_fixed_array', 'args': ['\'to_uint256\'', 2], 'type': 'text'},
  'uint256[4]': {'function': 'to_fixed_array', 'args': ['\'to_uint256\'', 4], 'type': 'text'},
  'address[2]': {'function': 'to_fixed_array', 'args': ['\'address\'', 2], 'type': 'text'},
  'address[4]': {'function': 'to_fixed_array', 'args': ['\'address\'', 4], 'type': 'text'},
  'bytes20': {'function': 'to_fixed_bytes', 'args': [20], 'type': 'text'}
}

export function fromDir(startPath, filter, callback) {
  console.log('starting from dir ' + startPath + '/');

  if (!fs.existsSync(startPath)) {
    console.log("no dir ", startPath);
    return;
  }

  const files = fs.readdirSync(startPath);
  for (let i = 0; i < files.length; i++) {
    const filename = path.join(startPath, files[i]);
    const stat = fs.lstatSync(filename);
    if (stat.isDirectory()) {
      fromDir(filename, filter, callback); //recurse
    } else if (filter.test(filename)) callback(filename);
  }
}

const folder = 'metadata'

export function writeCsvFiles(labels, contracts, events, abis, name) {
  console.log(`writing into csv files ${name}`)

  const valuesLabels = [...labels].map(o => ({name: o}))
  stringify(valuesLabels, {header: true}).pipe(fs.createWriteStream(`${folder}/${name}-label.csv`));

  // create table contract (address varchar(42) primary key, name text, label text references label);
  const valuesContract = []
  contracts.forEach((v, k) => {
    valuesContract.push({
      address: k,
      name: v.name,
      label: v.label
    })
  })
  stringify(valuesContract, {header: true}).pipe(fs.createWriteStream(`${folder}/${name}-contract.csv`));

  // create table abi (signature varchar(512) primary key, name text not null, hash text not null, unpack varchar(1024) not null, json varchar(1024) not null, canonical text not null, table_name text not null);
  const valuesAbi = []
  abis.forEach((v, k) => {
    valuesAbi.push({
      signature: k,
      name: v.name,
      hash: v.hash,
      unpack: v.unpack,
      json: v.json,
      canonical: v.canonical,
      table_name: v.table_name
    })
  })
  stringify(valuesAbi, {header: true}).pipe(fs.createWriteStream(`${folder}/${name}-abi.csv`));

  // create table event (contract_address varchar(42) references contract, abi_signature varchar(512) references abi, primary key (contract_address, abi_signature));
  const valuesEvent = [...events].map(o => {
    const e = JSON.parse(o)
    return {
      contract_address: e.contract_address,
      abi_signature: e.abi_signature
    }
  })
  stringify(valuesEvent, {header: true}).pipe(fs.createWriteStream(`${folder}/${name}-event.csv`));
}

export function writeSqlViewFilesFromAbis(labels, contracts, events, abis, contractEvents, name) {
  const fileCreateLabel = fs.createWriteStream(`${folder}/${name}-create-label-schema.sql`, {flags: 'w'})
  labels.forEach(a => {
    fileCreateLabel.write(`drop schema "${a}" cascade;\ncreate schema "${a}";\n`)
    fileCreateLabel.write(`grant usage on schema "${a}" to redash;\n`)
    // fileCreateLabel.write(`grant select on all tables in schema "${a}" to redash;\n`)
    fileCreateLabel.write(`alter default privileges in schema "${a}" grant select on tables to redash;\n`)
  })
  fileCreateLabel.end()

  const fileDropLabel = fs.createWriteStream(`${folder}/${name}-drop-label-schema.sql`, {flags: 'w'})
  labels.forEach(a => {
    fileDropLabel.write(`drop schema "${a}" cascade;\n`)
  })
  fileDropLabel.end()

  const fileEventView = fs.createWriteStream(`${folder}/${name}-create-event-view.sql`, {flags: 'w'})
  fileEventView.write('drop schema event cascade;\ncreate schema event;\nset search_path to public;\n')
  fileEventView.write(`grant usage on schema event to redash;\n`)
  fileEventView.write(`alter default privileges in schema event grant select on tables to redash;\n`)
  abis.forEach(v => {
    fileEventView.write(`create or replace view event."${v.table_name}" as select ${v.unpack}, address contract_address, transaction_hash evt_tx_hash, log_index evt_index, block_timestamp evt_block_time, block_number evt_block_number from data.logs where topic0 = '${v.hash}';\n`)
  })
  fileEventView.end()

  const fileContractView = fs.createWriteStream(`${folder}/${name}-create-contract-view.sql`, {flags: 'w'})
  contractEvents.forEach((v, k) => {
    //todo instead of comparing with lower(), lowercase all contract addresses at the insert
    fileContractView.write(`create or replace view ${k} as select v.* from event."${v.abi_table_name}" v left join metadata.event e on lower(e.contract_address) = lower(v.contract_address) left join metadata.contract c on lower(e.contract_address) = lower(c.address) where e.abi_signature = '${v.abi_signature}' and c.label = '${v.contract_label}' and c.name = '${v.contract_name}';\n`)
  })
  fileContractView.end()
}

export function typeToName(t, i) {
  return `${t.replace('[]', '_')}_${i}`
}

export function eventTableName(s) {
  return s.replace(/[(\[\],]/g, '_').replace(/[)]/g, '').substring(0, 127)
}

export function contractEventTableName(label, contract_name, abi_name) {
  return `${label}."${contract_name}_evt_${abi_name}"`
}

export function writeSqlViewFilesFromSignatures(records, name) {
  const sqlCreateView = records.map(o => `create or replace view events.${eventTableName(o.signature)} as select address, transaction_hash, block_timestamp, date, ${o.unpack} from data.logs where topic0 = '${o.hash}'`).join(';\n')

  fs.writeFileSync(`${folder}/${name}-create-event-view.sql`, ['set search_path to public', sqlCreateView].join(';\n'))
}

