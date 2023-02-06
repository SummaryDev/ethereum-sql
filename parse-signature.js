import {supportedTypesDict, typeToName} from './util.js'

export function parseEventSignature(s) {

  const args = []
  const json = []

  // split signature like Transfer(address,address,uint256) into Transfer address address uint256
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
    const type = parts[i]
    const t = supportedTypesDict[type]
    const name = typeToName(type, i)

    if (!t) {
      console.warn(`skipping abi ${abiName} for unsupported type ${type}`)
      return
    }

    let a
    const dataArg = ['data::text'].concat(t.args).join()
    const topicArg = [`topics[${i}]::text`].concat(t.args).join()

    if(i === 1) {
      a = `case when get_array_length(topics) > 1 then ${t.function}(2, ${topicArg}) else ${t.function}(2, ${dataArg}) end`
    } else if(i === 2) {
      a = `case when get_array_length(topics) > 2 then ${t.function}(2, ${topicArg}) else case when get_array_length(topics) = 2 then ${t.function}(2, ${dataArg}) else ${t.function}(2 + 64, ${dataArg}) end end`
    } else if(i === 3) {
      a = `case when get_array_length(topics) > 3 then ${t.function}(2, ${topicArg}) else case when get_array_length(topics) = 3 then ${t.function}(2, ${dataArg}) when get_array_length(topics) = 2 then ${t.function}(2 + 64, ${dataArg}) else ${t.function}(2 + 64*2, ${dataArg}) end end`
    } else {
      a = `${t.function}(2 + 64 * (${i} - get_array_length(topics)), ${dataArg})`
    }

    args.push(`${a} as "${name}"`)

    json.push(`'${name}', ${a}`) // todo a cludge to get around a possible bug in having case inside object function, replace with an array(value, raw)
  }

  return {
    name: abiName,
    unpack: `${args.join()}`,
    json: `object(${json.join()})`
  }
}
