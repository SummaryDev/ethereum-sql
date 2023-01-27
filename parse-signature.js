import {supportedTypesDict} from './util.js'

export function parseEventSignature(s) {

  const types = []
  const args = []
  const json = []
  const columns = []

  const parts = s.split(/[,()]/).filter(Boolean)

  if (parts.length === 0) {
    console.warn(`skipping signature ${s} for cannot split it`)
    return
  }

  const abiName = parts[0]

  if (parts.length < 2) {
    console.warn(`skipping abi ${abiName} for no inputs`) // todo allow no input abis?
    return
  }

  for (let i = 1; i < parts.length; i++) {
    const input = {type: parts[i], name: `${parts[i].replace('[]', '_')}_${i}`}
    const t = supportedTypesDict[input.type]

    if (!t) {
      console.warn(`skipping abi ${abiName} for unsupported input type ${input.type}`)
      return
    }

    types.push(input.type)
    columns.push(`${input.name} ${t.type}`)

    let arg
    const dataArg = ['data::text'].concat(t.args).join()
    const topicArg = [`topics[${i}]::text`].concat(t.args).join()

    if(i === 1) {
      arg = `case when get_array_length(topics) > 1 then ${t.function}(2, ${topicArg}) else ${t.function}(2, ${dataArg}) end`
    } else if(i === 2) {
      arg = `case when get_array_length(topics) > 2 then ${t.function}(2, ${topicArg}) else case when get_array_length(topics) = 2 then ${t.function}(2, ${dataArg}) else ${t.function}(2 + 64, ${dataArg}) end end`
    } else if(i === 3) {
      arg = `case when get_array_length(topics) > 3 then ${t.function}(2, ${topicArg}) else case when get_array_length(topics) = 3 then ${t.function}(2, ${dataArg}) when get_array_length(topics) = 2 then ${t.function}(2 + 64, ${dataArg}) else ${t.function}(2 + 64*2, ${dataArg}) end end`
    } else {
      arg = `${t.function}(2 + 64 * (${i} - get_array_length(topics)), ${dataArg})`
    }

    args.push(`${arg} as "${input.name}"`)

    // const a = []

    // if (input.indexed) {
    //   a.push(`topics[${counterTopic}]::text`)
    //   typesIndexed.push(`${input.type}_topic${counterTopic}`)
    //   typesIndexedWithNames.push(`${input.type}_${input.name}`)
    //   args.push(`${t.function}(2, ${a.concat(t.args).join()}) "topic${counterTopic}"`)
    //   counterTopic++
    // } else {
    //   a.push(`data::text`)
    //   typesIndexed.push(`${input.type}_data${counterData}`)
    //   typesIndexedWithNames.push(`${input.type}_${input.name}_d`)
    //   args.push(`${t.function}(2, ${a.concat(t.args).join()}) "data${counterData}"`)
    //   counterData++
    // }
    //
    // if (counterData > 1) {
    //   // console.warn(`skipping abi ${abiName} for data having more than one input`)
    //   return
    // }
    //
    // argsWithNames.push(`${t.function}(2, ${a.concat(t.args).join()}) "${input.name}"`)
    json.push(`'${input.name}', ${arg}`)
  }

  // const hash = '0x' + keccak256(`${abiName}(${types.join()})`).toString('hex')

  return {
    name: abiName,
    unpack: `${args.join()}`,
    json: `object(${json.join()})`,
    columns: columns.join()
  }
}
