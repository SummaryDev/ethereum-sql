import * as path from 'path';
import * as fs from 'fs';
import keccak256 from 'keccak256';

function parseEventAbi(abi) {
  if (abi.anonymous) {
    console.log('skipping abi anonymous')
    return
  }

  if (abi.type !== 'event') {
    console.warn('skipping abi for abi type ' + abi.type)
    return
  }

  const supportedTypesDict = {
    'address': {'function': 'to_address', 'args': [], 'type': 'text'},
    'uint256': {'function': 'to_uint256', 'args': [], 'type': 'decimal'},
    'address[]': {'function': 'to_array', 'args': ['address'], 'type': 'text'}, // todo what should be the result column type of arrays? not text but super or array?
    'uint256[]': {'function': 'to_array', 'args': ['to_uint256'], 'type': 'text'},
    'string[]': {'function': 'to_array', 'args': ['string'], 'type': 'text'},
    'bytes[]': {'function': 'to_array', 'args': ['bytes'], 'type': 'text'},
    'bool[]': {'function': 'to_array', 'args': ['bool'], 'type': 'text'},
    'bytes32': {'function': 'to_fixed_bytes', 'args': [32], 'type': 'text'},
    'bool': {'function': 'to_bool', 'args': [], 'type': 'bool'},
    'string': {'function': 'to_string', 'args': [], 'type': 'text'},
    'bytes': {'function': 'to_bytes', 'args': [], 'type': 'text'},
    'uint128': {'function': 'to_uint128', 'args': [], 'type': 'decimal'},
    'uint64': {'function': 'to_uint64', 'args': [], 'type': 'decimal'},
    'bytes4': {'function': 'to_fixed_bytes', 'args': [4], 'type': 'text'},
    'uint32': {'function': 'to_uint32', 'args': [], 'type': 'decimal'},
    'bytes16': {'function': 'to_fixed_bytes', 'args': [16], 'type': 'text'},
    'uint256[3]': {'function': 'to_fixed_array', 'args': ['to_uint256', 3], 'type': 'text'},
    'uint256[2]': {'function': 'to_fixed_array', 'args': ['to_uint256', 2], 'type': 'text'},
    'uint256[4]': {'function': 'to_fixed_array', 'args': ['to_uint256', 4], 'type': 'text'},
    'address[2]': {'function': 'to_fixed_array', 'args': ['address', 2], 'type': 'text'},
    'address[4]': {'function': 'to_fixed_array', 'args': ['address', 4], 'type': 'text'},
    'bytes20': {'function': 'to_fixed_bytes', 'args': [20], 'type': 'text'}
  };

  const types = []
  const typesIndexed = []
  const typesIndexedWithNames = []
  const functionsColumns = []
  const functionsColumnsWithNames = []
  const functionsJson = []
  const columns = []

  let counterTopic = 1
  let counterData = 0

  const abiName = abi.name

  if (abi.inputs.length === 0) {
    console.warn(`skipping abi ${abiName} for no inputs`) // todo allow no input abis?
    return
  }

  for (let i = 0; i < abi.inputs.length; i++) {
    const input = abi.inputs[i]
    const t = supportedTypesDict[input.type]

    if (!t) {
      console.warn(`skipping abi ${abiName} for unsupported input type ${input.type}`)
      return
    }

    types.push(input.type)
    columns.push(`${input.name} ${t.type}`)

    const a = []

    if (input.indexed) {
      a.push(`topics[${counterTopic}]::text`)
      typesIndexed.push(`${input.type}_topic${counterTopic}`)
      typesIndexedWithNames.push(`${input.type}_${input.name}`)
      functionsColumns.push(`${t.function}(2, ${a.concat(t.args).join()}) "topic${counterTopic}"`)
      counterTopic++
    } else {
      a.push(`data::text`)
      typesIndexed.push(`${input.type}_data${counterData}`)
      typesIndexedWithNames.push(`${input.type}_${input.name}_d`)
      functionsColumns.push(`${t.function}(2, ${a.concat(t.args).join()}) "data${counterData}"`)
      counterData++
    }

    if (counterData > 1) {
      console.warn(`skipping abi ${abiName} for data having more than one input`)
      return
    }

    functionsColumnsWithNames.push(`${t.function}(2, ${a.concat(t.args).join()}) "${input.name}"`)
    functionsJson.push(`''${input.name}'',${t.function}(2, ${a.concat(t.args).join()})`)
  }

  const hash = '0x' + keccak256(`${abiName}(${types.join()})`).toString('hex')

  return {
    name: abiName,
    hash: hash,
    signature: `${abiName}_${typesIndexedWithNames.join('_')}`,
    signature_typed: `${abiName}_${typesIndexed.join('_')}`,
    unpack: `${functionsColumnsWithNames.join()}`,
    unpack_typed: `${functionsColumns.join()}`,
    json: `object(${functionsJson.join()})`,
    columns: columns.join()
  }
}

function fromDir(startPath, filter, callback) {
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

function processBlockchainEtlFiles() {
  const records = []

  fromDir('../ethereum-etl-airflow/dags/resources/stages/parse/table_definitions/', /\.json$/, filename => {
    console.log(filename)

    const j = JSON.parse(fs.readFileSync(filename))
    // console.log(j)

    const address = j.parser.contract_address

    if (!address) {
      console.warn(`skipping ${filename} for missing address`)
      return
    }

    if (address.length !== 42) {
      console.warn(`skipping ${filename} for address length ${address.length}`)
      return
    }

    const contract = {
      appName: j.table.dataset_name,
      address: j.parser.contract_address,
      name: j.table.table_name.split('_event_')[0]
    }

    const abi = parseEventAbi(j.parser.abi)

    if (abi) {
      const r = {
        contract: contract,
        abi: abi
      }
      // console.log(JSON.stringify(r))
      records.push(r)
    }
  })

  const apps = [...new Set(records.map(r => r.contract.appName))]
  const valuesApps = apps.map(a => `('${a}')`)
  const sqlApp = `insert into app (name) values ${valuesApps.join()}`

  const contracts = [...new Map(records.map(r => r.contract).map(item => [item['address'], item])).values()]
  const valuesContract = contracts.map(o => `('${o.address}', '${o.name}', '${o.appName}')`)
  const sqlContract = `insert into contract (address, name, app_name) values ${valuesContract.join()}`

  const abis = [...new Set(records.map(o => JSON.stringify(o.abi)))].map(s => JSON.parse(s))
  const valuesAbi = abis.map(o => `('${o.signature}', '${o.hash}', '${o.name}', '${o.unpack}', '${o.json}', '${o.columns}', '${o.signature_typed}', '${o.unpack_typed}')`)
  const sqlAbi = `insert into abi (signature, hash, name, unpack, json, columns, signature_typed, unpack_typed) values ${valuesAbi.join()}` // todo on conflict update? update set unpack = excluded.unpack, columns = excluded.columns

  const valuesEvent = [...new Set(records.map(o => `('${o.contract.address}', '${o.abi.signature}')`))]
  const sqlEvent = `insert into event (contract_address, abi_signature) values ${valuesEvent.join()}`

  // fs.writeFileSync('./parse-contracts-blockchain-etl-postgres-out.sql', [sqlApp, ' on conflict(address) do nothing; truncate table contract cascade', sqlContract, 'truncate table abi cascade', sqlAbi + ' on conflict(signature) do nothing', sqlEvent].join(';\n'))
  fs.writeFileSync('./parse-contracts-blockchain-etl-postgres-out.sql', ['set search_path to eth', 'truncate table app cascade', sqlApp, 'truncate table contract cascade', sqlContract, 'truncate table abi cascade', sqlAbi, 'truncate table event cascade', sqlEvent].join(';\n'))

  fs.writeFileSync('./parse-contracts-blockchain-etl-redshift-out.sql', ['set search_path to eth', 'truncate table app', sqlApp, 'truncate table contract', sqlContract, 'truncate table abi', sqlAbi, 'truncate table event', sqlEvent].join(';\n'))

  const sqlDropView = abis.map(o => `drop view if exists "${o.signature}"`)

  fs.writeFileSync('./parse-contracts-blockchain-etl-drop-view-out.sql', sqlDropView.join(';\n'))

  const sqlCreateView = abis.map(o => `create or replace view "event_${o.signature}" as select address, transaction_hash, block_timestamp, date, ${o.unpack} from logs`)

  fs.writeFileSync('./parse-contracts-blockchain-etl-create-view-out.sql', sqlCreateView.join(';\n'))

}

processBlockchainEtlFiles()