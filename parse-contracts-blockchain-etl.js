import * as path from 'path';
import * as fs from 'fs';
import keccak256 from 'keccak256';

function processAbi(abi) {
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
    'uint256': {'function': 'to_uint128_array_or_null', 'args': [], 'type': 'decimal'},
    'address[]': {'function': 'to_array', 'args': ['address'], 'type': 'text'}, // todo what should be the result column type of arrays? not text but super or array?
    'uint256[]': {'function': 'to_array', 'args': ['to_uint128_array_or_null'], 'type': 'text'},
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
    'uint256[3]': {'function': 'to_fixed_array', 'args': ['to_uint128_array_or_null', 3], 'type': 'text'},
    'uint256[2]': {'function': 'to_fixed_array', 'args': ['to_uint128_array_or_null', 2], 'type': 'text'},
    'uint256[4]': {'function': 'to_fixed_array', 'args': ['to_uint128_array_or_null', 4], 'type': 'text'},
    'address[2]': {'function': 'to_fixed_array', 'args': ['address', 2], 'type': 'text'},
    'address[4]': {'function': 'to_fixed_array', 'args': ['address', 4], 'type': 'text'},
    'bytes20': {'function': 'to_fixed_bytes', 'args': [20], 'type': 'text'}
  };

  const types = []
  const functionsColumns = []
  const functionsJson = []
  const columns = []

  let indexTopic = 1
  let indexData = 0

  const abiName = abi.name

  if(abi.inputs.length === 0) {
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
      a.push(`topics[${indexTopic}]::text`)
      indexTopic++
    } else {
      a.push(`data::text`)
      indexData++
    }

    if (indexData > 1) {
      console.warn(`skipping abi ${abiName} for data having more than one input`)
      return
    }

    functionsColumns.push(`${t.function}(2, ${a.concat(t.args).join()}) "${input.name}"`)
    functionsJson.push(`''${input.name}'',${t.function}(2, ${a.concat(t.args).join()})`)
  }

  const signature = `${abiName}(${types.join()})`
  const hash = '0x' + keccak256(signature).toString('hex')

  return {name: abiName, signature: signature, hash: hash, unpack: `${functionsColumns.join()}`, json: `object(${functionsJson.join()})`, columns: columns.join()}
}

function fromDir(startPath, filter, callback) {
  console.log('starting from dir '+startPath+'/');

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

function processFiles() {
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

    const abi = processAbi(j.parser.abi)

    if (abi) {
      const r = {
        contract: contract,
        abi: abi
      }
      // console.log(JSON.stringify(r))
      records.push(r)
    }
  })

  // console.log(JSON.stringify(records))

  const apps = [...new Set(records.map(r => r.contract.appName))];
  // console.log(apps)

  const valuesApps = apps.map(a => `('${a}')`)
  const sqlApps = `insert into app (name) values ${valuesApps.join()} on conflict(name) do nothing;`
  // console.log(sqlApps);

  const contracts = [...new Set(records.map(r => JSON.stringify(r.contract)))].map(s => JSON.parse(s))
  // console.log(contracts)

  const valuesContract = contracts.map(o => `('${o.address}', '${o.name}', '${o.appName}')`)
  const sqlContracts = `insert into contract (address, name, app_name) values ${valuesContract.join()} on conflict(address) do nothing;`
  // console.log(sqlContracts)

  const abis = [...new Set(records.map(o => JSON.stringify(o.abi)))].map(s => JSON.parse(s))
  // console.log(abis)

  const valuesAbi = abis.map(o => `('${o.hash}', '${o.name}', '${o.signature}', '${o.unpack}', '${o.json}', '${o.columns}')`)
  const sqlEvents = `insert into abi (hash, name, signature, unpack, json, columns) values ${valuesAbi.join()} on conflict(hash) do nothing;` // todo on conflict update? update set unpack = excluded.unpack, columns = excluded.columns
  // console.log(sqlEvents)

  const valuesEvent = records.map(o => `('${o.contract.address}', '${o.abi.hash}')`)
  const sqlContractEvents = `insert into event (contract_address, abi_hash) values ${valuesEvent.join()} on conflict(contract_address, abi_hash) do nothing;`
  // console.log(sqlContractEvents)

  fs.writeFileSync('./parse-contracts-blockchain-etl-out.sql', sqlApps + '\ntruncate table contract cascade;' + sqlContracts + '\ntruncate table abi cascade;\n' + sqlEvents + '\n' + sqlContractEvents)

}

processFiles()