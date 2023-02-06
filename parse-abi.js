import keccak256 from 'keccak256';
import {supportedTypesDict, typeToName} from './util.js'

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
  const args = []
  const json = []
  const columns = []

  let counterTopic = 1
  let counterData = 0

  const abiName = abi.name

  if (abi.inputs.length === 0) {
    console.warn(`skipping abi ${abiName} for no inputs`) // todo allow no input abis?
    return
  }

  let prevInputIndexed

  for (let i = 0; i < abi.inputs.length; i++) {
    const input = abi.inputs[i]
    const t = supportedTypesDict[input.type]

    if (!t) {
      // console.warn(`skipping abi ${abiName} for unsupported input type ${input.type}`)
      return
    }

    if (i !== 0 && !prevInputIndexed && input.indexed) {
      // console.warn(`indexed input ${JSON.stringify(input)} after non indexed in abi ${abiName}`)
    }
    prevInputIndexed = input.indexed

    input.nameFromType = typeToName(input.type, i)

    if(!input.name)
      input.name = input.nameFromType

    types.push(input.type)
    columns.push(`${input.nameFromType} as ${input.name}`)

    const a = []

    if (input.indexed) {
      a.push(`topics[${counterTopic}]::text`)
      typesWithNames.push(`${input.type}_${input.name}`)
      counterTopic++
    } else {
      a.push(`data::text`)
      typesWithNames.push(`${input.type}_${input.name}_d`)
      counterData++
    }

    if (counterData > 1) {
      // console.warn(`truncating abi ${abiName} for data having more than one input`)
      // return
      break
    }

    args.push(`${t.function}(2, ${a.concat(t.args).join()}) "${input.name}"`)
    json.push(`''${input.name}'',${t.function}(2, ${a.concat(t.args).join()})`)
  }

  const signature_typed = `${abiName}(${types.join()})`
  const signature_named = `${abiName}_${typesWithNames.join('_')}`

  const hash = '0x' + keccak256(signature_typed).toString('hex')

  return {
    name: abiName,
    hash: hash,
    signature: signature_named,
    signature_typed: signature_typed,
    unpack: `${args.join()}`,
    json: `object(${json.join()})`,
    // columns: columns.join()
  }
}
