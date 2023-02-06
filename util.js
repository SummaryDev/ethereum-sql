import * as fs from 'fs';
import * as path from 'path';
import { stringify } from 'csv';

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

export function writeCsvFiles(records, name) {
  console.log(`writing ${records.length} records into csv files ${name}`)

  const apps = uniqueApps(records)
  const valuesApp = apps.map(o => ({name: o}))
  stringify(valuesApp, {header: true}).pipe(fs.createWriteStream(`${folder}/${name}-app.csv`));

  const contracts = uniqueContracts(records)
  const valuesContract = contracts.map(o => ({address: o.address, name: o.name, app_name: o.appName}))
  stringify(valuesContract, {header: true}).pipe(fs.createWriteStream(`${folder}/${name}-contract.csv`));

  const abis = uniqueAbis(records)
  const valuesAbi = abis.map(o => ({signature: o.signature, name: o.name, hash: o.hash, unpack: o.unpack, json: o.json.replace(/''/g, '\''), signature_typed: o.signature_typed}))
  stringify(valuesAbi, {header: true}).pipe(fs.createWriteStream(`${folder}/${name}-abi.csv`));

  const events = uniqueEvents(records)
  const valuesEvent = events.map(o => ({contract_address: o.contract_address, abi_signature: o.abi_signature}))
  stringify(valuesEvent, {header: true}).pipe(fs.createWriteStream(`${folder}/${name}-event.csv`));
}

export function writeSqlViewFilesFromAbis(records, name) {
  const apps = uniqueApps(records)

  const sqlCreateAppSchema = apps.map(a => `create schema "${a}"`).join(';\n')
  fs.writeFileSync(`${folder}/${name}-create-app-schema.sql`, ['set search_path to public', sqlCreateAppSchema].join(';\n'))

  const sqlDropAppSchema = apps.map(a => `drop schema "${a}" cascade`).join(';\n')
  fs.writeFileSync(`${folder}/${name}-drop-app-schema.sql`, ['set search_path to public', sqlDropAppSchema].join(';\n'))

  const contractEvents = uniqueContractEvents(records)

  const sqlCreateContractView = contractEvents.map(o => `create or replace view ${o.app_name}."${o.contract_name}_evt_${o.abi_name}" as select o.* from events.${signatureToName(o.abi_signature)} o left join eth.event e on o.address = e.contract_address left join eth.contract c on o.address = c.address where e.abi_signature = '${o.abi_signature}' and c.app_name = '${o.app_name}' and c.name = '${o.contract_name}'`).join(';\n')

  fs.writeFileSync(`${folder}/${name}-create-contract-view.sql`, [/*'set enable_case_sensitive_identifier to true', */'set search_path to public', sqlCreateContractView].join(';\n'))

  const abis = uniqueAbis(records)

  const sqlCreateView = abis.map(o => `create or replace view events."${signatureToName(o.signature)}" as select ${o.unpack}, address, transaction_hash, block_timestamp, date from eth.logs where topics[0] = '${o.hash}'`).join(';\n')

  fs.writeFileSync(`${folder}/${name}-create-event-view.sql`, [/*'set enable_case_sensitive_identifier to true', */'create schema if not exists events', 'set search_path to public', sqlCreateView].join(';\n'))

  // const sqlDropView = abis.map(o => `drop view "events.${o.signature}"`).join(';\n')
  //
  // fs.writeFileSync(`${folder}/${name}-drop-view.sql`, ['set search_path to public', sqlDropView].join(';\n'))
}

export function typeToName(t, i) {
  return `${t.replace('[]', '_')}_${i}`
}

export function signatureToName(s) {
  return s.replace(/[(\[\],]/g, '_').replace(/[)]/g, '')
}

export function writeSqlViewFilesFromSignatures(records, name) {
  const sqlCreateView = records.map(o => `create or replace view events.${signatureToName(o.signature)} as select address, transaction_hash, block_timestamp, date, ${o.unpack} from eth.logs where topics[0] = '${o.hash}'`).join(';\n')

  fs.writeFileSync(`${folder}/${name}-create-event-view.sql`, ['set search_path to public', sqlCreateView].join(';\n'))
}

export function writeSqlInsertFiles(records, name) {
  const apps = uniqueApps(records)
  const valuesApp = apps.map(a => `('${a}')`)
  const sqlApp = `insert into app (name) values ${valuesApp.join()}`

  const contracts = uniqueContracts(records)
  const valuesContract = contracts.map(o => `('${o.address}', '${o.name}', '${o.appName}')`)
  const sqlContract = `insert into contract (address, name, app_name) values ${valuesContract.join()}`

  const abis = uniqueAbis(records)
  const valuesAbi = abis.map(o => `('${o.signature}', '${o.hash}', '${o.name}', '${o.unpack}', '${o.json}', '${o.signature_typed}')`)
  const sqlAbi = `insert into abi (signature, hash, name, unpack, json, signature_typed) values ${valuesAbi.join()}` // todo on conflict update? update set unpack = excluded.unpack, columns = excluded.columns

  const events = uniqueEvents(records)
  const valuesEvent = events.map(o => `('${o.contract_address}', '${o.abi_signature}')`)
  const sqlEvent = `insert into event (contract_address, abi_signature) values ${valuesEvent.join()}`

  // fs.writeFileSync('./contracts-blockchain-etl-postgres.sql', [sqlApp, ' on conflict(address) do nothing; truncate table contract cascade', sqlContract, 'truncate table abi cascade', sqlAbi + ' on conflict(signature) do nothing', sqlEvent].join(';\n'))
  fs.writeFileSync(`${folder}/${name}-postgres.sql`, ['set search_path to eth', 'truncate table app cascade', sqlApp, 'truncate table contract cascade', sqlContract, 'truncate table abi cascade', sqlAbi, 'truncate table event cascade', sqlEvent].join(';\n'))

  fs.writeFileSync(`${folder}/${name}-redshift.sql`, ['set search_path to eth', 'truncate table app', sqlApp, 'truncate table contract', sqlContract, 'truncate table abi', sqlAbi, 'truncate table event', sqlEvent].join(';\n'))
}

// apps (projects) unique by name
function uniqueApps(records) {
  return [...new Set(records.map(r => r.contract.appName))]
}

// contracts unique by address
function uniqueContracts(records) {
  return [...new Map(records.map(r => r.contract).map(item => [item['address'], item])).values()]
}

// abis unique by all abi attributes
function uniqueAbis(records) {
  const j = records.map(o => JSON.stringify(o.abi))
  return [...new Set(j)].map(s => JSON.parse(s))
}

// event (link between a contract and one of its abis) unique by contract address and abi signature
function uniqueEvents(records) {
  return records.map(o => ({contract_address: o.contract.address, abi_signature: o.abi.signature}))
}

// event unique by contract address and abi signature
function uniqueContractEvents(records) {
  const j = records.map(o => JSON.stringify(({app_name: o.contract.appName, contract_name: o.contract.name, abi_name: o.abi.name, abi_signature: o.abi.signature})))
  return [...new Set(j)].map(s => JSON.parse(s))
}
