import keccak256 from 'keccak256';
import {supportedTypesDict, typeToName, signatureToName} from './util.js'

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
  const typesWithNames = []
  const typesWithNamesIndexed = []
  const argsUnpack = []
  const argsJson = []
  const columns = []

  let counterTopic = 1
  let counterData = 0

  const abiName = abi.name

  if (abi.inputs.length === 0) {
    console.warn(`skipping abi ${abiName} for no inputs`) // todo allow no input abis?
    return
  }

  // let prevInputIndexed

  for (let i = 0; i < abi.inputs.length; i++) {
    const input = abi.inputs[i]
    const t = supportedTypesDict[input.type]

    if (!t) {
      // todo use raw hex value for unsupported type?
      // console.warn(`skipping abi ${abiName} for unsupported input type ${input.type}`)
      // console.warn(`skipping abi for unsupported input type ${input.type}`)
      return
    }

    // if (counterData > 1) {
    //   // console.warn(`truncating abi ${abiName} for data having more than one input`)
    //   // console.warn(`truncating abi for data having more than one input ${JSON.stringify(abi)}`)
    //   break
    // }

    // if (i !== 0 && !prevInputIndexed && input.indexed) {
    //   console.warn(`indexed input ${JSON.stringify(input)} after non indexed in abi ${abiName}`)
    // }
    // prevInputIndexed = input.indexed

    input.nameFromType = typeToName(input.type, i)

    if(!input.name)
      input.name = input.nameFromType

    types.push(input.type)
    columns.push(`${input.nameFromType} as ${input.name}`)

    const a = []

    if (input.indexed) {
      a.push(2)
      a.push(`topics[${counterTopic}]::text`)
      typesWithNames.push(`${input.type}_${input.name}`)
      typesWithNamesIndexed.push(`${input.type} indexed ${input.name}`)
      counterTopic++
    } else {
      a.push(2 + counterData * 64)
      a.push(`data::text`)
      typesWithNames.push(`${input.type}_${input.name}_d`)
      typesWithNamesIndexed.push(`${input.type} ${input.name}`)
      counterData++
    }

    argsUnpack.push(`${t.function}(${a.concat(t.args).join()}) "${input.name}"`)
    argsJson.push(`'${input.name}',${t.function}(${a.concat(t.args).join()})`)
  }

  const signature_typed = `${abiName}(${types.join()})`
  const signature_named = `${abiName}_${typesWithNames.join('_')}`
  const signature_indexed = `${abiName}(${typesWithNamesIndexed.join(',')})`
  const table_name = signatureToName(signature_named)

  const hash = '0x' + keccak256(signature_typed).toString('hex')

  const unpack = `${argsUnpack.join()}`
  const json = `object(${argsJson.join()})`

  return {
    name: abiName,
    hash: hash,
    signature: signature_indexed,
    canonical: signature_typed,
    table_name: table_name,
    unpack: unpack,
    json: json,
    // columns: columns.join()
  }
}
