import * as fs from 'fs';
import {parseEventAbiWithLabels} from './parse-abi.js';
import {fromDir, writeCsvFiles, writeSqlViewFilesFromAbis} from './util.js';
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

        parseEventAbiWithLabels(d, labels, contracts, abis, events, contractEvents)

        countRecords++

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
