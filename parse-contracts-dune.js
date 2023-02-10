import * as fs from 'fs';
import {parseEventAbi} from './parse-abi.js';
import {fromDir, writeCsvFiles, writeSqlInsertFiles, writeSqlViewFilesFromAbis} from './util.js';
import JSONStream from 'JSONStream';

function addRecord(records, d) {
  if (!d.abi || !d.address || !d.namespace || !d.name) {
    console.warn(`skipping record for missing fields in ${JSON.stringify(d)}`)
    return
  }

  if (d.address.length !== 42) {
    console.warn(`skipping record ${d.address} for address length ${d.address.length}`)
    return
  }

  const contract = {
    appName: d.namespace,
    address: d.address.replace('\\', '0'),
    name: d.name
  }

  const abis = d.abi.filter(o => o.type === 'event' && !o.anonymous && o.inputs && o.inputs.length > 0)

  for (const a of abis) {
    const abi = parseEventAbi(a)

    if (abi) {
      const r = {
        contract: contract,
        abi: abi
      }
      // console.log(JSON.stringify(r))
      records.push(r)
    }
  }
}

function processDuneFiles() {
  const promises = []

  // /\.json$/
  // /\parse-dune-contracts-12-out.json$/
  fromDir('./data/dune/contracts', /-out.json$/, filename => {
    console.log(filename)

    const records = []

    const jsonStream = JSONStream.parse('data.get_execution.execution_succeeded.data.*')

    const p = new Promise((resolve, reject) => {

      jsonStream.on('data', d => {
        addRecord(records, d)
      }).on('end', () => {
        resolve(records)
        console.log(`read ${records.length} records from ${filename}`)
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
    const allRecords = results.flat()
    console.log(`resolved ${results.length} results with ${allRecords.length} records total`)

    const name = 'parse-contracts-dune'

    writeCsvFiles(allRecords, name)
    writeSqlViewFilesFromAbis(allRecords, name)
  })

}

processDuneFiles()
