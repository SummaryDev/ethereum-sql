import keccak256 from 'keccak256';
import {supportedTypesDict} from './util.js'

export function parseEventAbi(abi) {
  if (abi.anonymous) {
    console.log('skipping abi anonymous')
    return
  }

  if (abi.type !== 'event') {
    console.warn('skipping abi for abi type ' + abi.type)
    return
  }

  const types = []
  const typesIndexed = []
  const typesIndexedWithNames = []
  const args = []
  const argsWithNames = []
  const json = []
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
      // console.warn(`skipping abi ${abiName} for unsupported input type ${input.type}`)
      return
    }

    if(!input.name)
      input.name = input.indexed ? `topic${counterTopic}` : `data${counterData}`

    types.push(input.type)
    columns.push(`${input.name} ${t.type}`)

    const a = []

    if (input.indexed) {
      a.push(`topics[${counterTopic}]::text`)
      typesIndexed.push(`${input.type}_topic${counterTopic}`)
      typesIndexedWithNames.push(`${input.type}_${input.name}`)
      args.push(`${t.function}(2, ${a.concat(t.args).join()}) "topic${counterTopic}"`)
      counterTopic++
    } else {
      a.push(`data::text`)
      typesIndexed.push(`${input.type}_data${counterData}`)
      typesIndexedWithNames.push(`${input.type}_${input.name}_d`)
      args.push(`${t.function}(2, ${a.concat(t.args).join()}) "data${counterData}"`)
      counterData++
    }

    if (counterData > 1) {
      // console.warn(`skipping abi ${abiName} for data having more than one input`)
      return
    }

    argsWithNames.push(`${t.function}(2, ${a.concat(t.args).join()}) "${input.name}"`)
    json.push(`''${input.name}'',${t.function}(2, ${a.concat(t.args).join()})`)
  }

  const hash = '0x' + keccak256(`${abiName}(${types.join()})`).toString('hex')

  return {
    name: abiName,
    hash: hash,
    signature: `${abiName}_${typesIndexedWithNames.join('_')}`,
    signature_typed: `${abiName}_${typesIndexed.join('_')}`,
    unpack: `${argsWithNames.join()}`,
    unpack_typed: `${args.join()}`,
    json: `object(${json.join()})`,
    columns: columns.join()
  }
}
