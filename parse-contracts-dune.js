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
  // /\.json$/
  // /\parse-dune-contracts-12-out.json$/
  fromDir('./data/dune/contracts', /01-out.json$/, filename => {
    console.log(filename)

    const name = filename.replace(/^.*[\\\/]/, '').replace('.json', '')
    const records = []

    const jsonStream = JSONStream.parse('data.get_execution.execution_succeeded.data.*')

    jsonStream.on('data', d => {
      addRecord(records, d)
    }).on('end', () => {
      writeCsvFiles(records, name)
      // writeSqlInsertFiles(records, name)
      writeSqlViewFilesFromAbis(records, name)
    }).on('error', e => {
      console.error('cannot parse json', e)
    })

    fs.createReadStream(filename).pipe(jsonStream)
  })

}

processDuneFiles()
