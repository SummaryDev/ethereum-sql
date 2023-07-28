import * as fs from 'fs';
import {parseEventAbiWithLabels} from './parse-abi.js';
import {fromDir, writeCsvFiles, writeSqlViewFilesFromAbis} from './util.js';
import JSONStream from 'JSONStream';

function parseAbiFilesForEvents() {
  const promises = []

  const project = 'beamswap'
  const labels = new Set()
  const contracts = new Map()
  const events = new Set()
  const abis = new Map()
  const contractEvents = new Map()

  fromDir(`./input/${project}`, /.json$/, filename => {
    console.log(filename)

    const contractAddress = filename.substr(filename.lastIndexOf('/')+1, 42)
    const contractName = filename.substring(filename.lastIndexOf('/')+1+42, filename.indexOf('.json'))
    const name = contractName.replace(/\s|\./g, '')

    let countRecords = 0;

    const jsonStream = JSONStream.parse('result')

    const p = new Promise((resolve, reject) => {

      jsonStream.on('data', datum => {
        const abi = JSON.parse(datum)

        const d = {abi: abi, address: contractAddress, namespace: project, name: name}

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

    console.log(`read ${labels.size} labels ${contracts.size} contracts ${events.size} events ${contractEvents.size} contractEvents ${abis.size} abis`)

    const name = `parse-abi`

    writeCsvFiles(labels, contracts, events, abis, name)
    writeSqlViewFilesFromAbis(labels, contracts, events, abis, contractEvents, name)
  })

}

parseAbiFilesForEvents()
