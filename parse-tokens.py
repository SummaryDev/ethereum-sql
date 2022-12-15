import json
import os

jsonDir = './eth'
jsonFiles = os.listdir(jsonDir)
csvFilePath = './tokens.csv'
csvFile = open(csvFilePath, "w")
columnNames = ['symbol','name','type','address','ens_address','decimals','website','logo','support','social']
csvDelimiter = '^'

i = 0
for file in jsonFiles:
    jsonFilePath = jsonDir + '/' + file
    jsonFile = open(jsonFilePath, "r")
    tokenJson = json.loads(jsonFile.read())
    print (tokenJson["symbol"])

    # print headers, only once
    if i == 0:
        headerStr = ''
        for column in columnNames:
            headerStr += column + csvDelimiter
        i += 1
        csvFile.write(headerStr[:-1] + '\n')

    # print values
    valuesStr = ''
    for column in columnNames:
        value = tokenJson[column]
        isInteger = isinstance(value, int)
        if isInteger == True:
            valuesStr += str(value) + csvDelimiter
        else:
            valuesStr += '\'' + str(value).replace('\'', '""') + '\'' + csvDelimiter
    csvFile.write(valuesStr[:-1] + '\n')
csvFile.close()    
