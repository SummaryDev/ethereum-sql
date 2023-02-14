import * as fs from 'fs';
import {parseEventAbi} from './parse-abi.js';
import {fromDir, writeCsvFiles, writeSqlViewFilesFromAbis, contractEventTableName} from './util.js';
import JSONStream from 'JSONStream';

function parseDuneFilesForEvents() {
  const promises = []

  const labels = new Set()
  const contracts = new Map()
  const events = new Set()
  const abis = new Map()
  const contractEvents = new Map()

  // /\.json$/
  // /\parse-dune-contracts-12-out.json$/
  fromDir('./data/dune/contracts', /.json$/, filename => {
    console.log(filename)

    let countRecords = 0;

    const jsonStream = JSONStream.parse('data.get_execution.execution_succeeded.data.*')

    const p = new Promise((resolve, reject) => {

      jsonStream.on('data', d => {
        if (!d.abi) {
          console.warn(`skipping record for missing abi in ${JSON.stringify(d)}`)
          return
        }

        if (!d.address) {
          console.warn(`skipping record for missing address in ${JSON.stringify(d)}`)
          return
        }

        if (!d.namespace) {
          console.warn(`skipping record for missing namespace in ${JSON.stringify(d)}`)
          return
        }

        if (!d.name) {
          console.warn(`skipping record for missing name in ${JSON.stringify(d)}`)
          return
        }

        if (d.address.length !== 42) {
          console.warn(`skipping record ${d.address} for address length ${d.address.length}`)
          return
        }

        countRecords++

        labels.add(d.namespace)

        const address = d.address.replace('\\', '0')

        contracts.set(address, {
          label: d.namespace,
          name: d.name
        })

        const dabis = d.abi.filter(o => o.type === 'event' && !o.anonymous && o.inputs && o.inputs.length > 0)

        for (const a of dabis) {
          const abi = parseEventAbi(a)

          if (abi) {
            abis.set(abi.signature, abi)

            events.add(JSON.stringify({
              contract_address: address,
              abi_signature: abi.signature,
            }))

            contractEvents.set(contractEventTableName(d.namespace, d.name, abi.name), {
              contract_label: d.namespace,
              contract_name: d.name,
              abi_signature: abi.signature,
              abi_table_name: abi.table_name,
            })
          }
        }
      }).on('end', () => {
        const m = `read ${countRecords} records from ${filename}`
        console.log(m)
        resolve(m)
      }).on('error', e => {
        const m = `cannot parse json in ${filename}`
        console.error(m, e)
        reject(m)
      })

    })

    promises.push(p)

    fs.createReadStream(filename).pipe(jsonStream)
  })

  Promise.all(promises).then(results => {
    console.log(`resolved results ${JSON.stringify(results)}`)

    console.log(`read ${labels.size} namespaces ${contracts.size} contracts ${events.size} events ${contractEvents.size} contractEvents ${abis.size} abis`)

    const name = 'parse-contracts-dune'

    writeCsvFiles(labels, contracts, events, abis, name)
    writeSqlViewFilesFromAbis(labels, contracts, events, abis, contractEvents, name)
  })

}

parseDuneFilesForEvents()
