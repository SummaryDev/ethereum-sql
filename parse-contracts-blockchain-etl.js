import * as path from 'path';
import * as fs from 'fs';
import parseEventAbi from './parse-abi';
import fromDir from './util';

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