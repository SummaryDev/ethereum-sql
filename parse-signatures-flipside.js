import * as fs from 'fs';
import {parseEventSignature} from './parse-signature.js';
import {fromDir, writeSqlViewFilesFromSignatures} from './util.js';
import {parse} from 'csv';
import keccak256 from 'keccak256';

function addRecord(records, d) {
  if (d.length < 2) {
    console.warn(`skipping record for missing fields in ${JSON.stringify(d)}`)
    return
  }

  if (d[0].length !== 66) {
    console.warn(`skipping record ${d[0]} for hash length ${d[0].length}`)
    return
  }

  const hash = '0x' + keccak256(d[1]).toString('hex')

  if (d[0].toLowerCase() !== hash) {
    console.warn(`skipping record ${JSON.stringify(d)} for incorrect hash`)
    return
  }

  const abi = parseEventSignature(d[1])

  if (abi) {
    abi.hash = hash
    abi.signature = d[1]
    // console.log(JSON.stringify(abi))
    records.push(abi)
  }
}

function processFlipsideFiles() {
  fromDir('./data/flipside/signatures', /event-signatures\.csv$/, filename => {
    console.log(filename)

    const records = []

    const name = filename.replace(/^.*[\\\/]/, '').replace('.csv', '')

    fs.createReadStream(filename)
      .pipe(parse({delimiter: ',', from_line: 1}))
      .on('data', d => {
        // console.log(d)
        addRecord(records, d)
      })
      .on('end', () => {
        writeSqlViewFilesFromSignatures(records, name)
      })
      .on('error', e => {
        console.error('cannot parse', e)
      })
  })

}

processFlipsideFiles()