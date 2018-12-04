const sqlString = require('sql-escape-string')
const { promisify } = require('util')
const xml2js = require('xml2js')

const xmlParser = new xml2js.Parser()
const xmlBuilder = new xml2js.Builder()

// Make an async-friendly version of the parser
const parsePromise = promisify(xmlParser.parseString)

// Escape col but replace outer '-s with "-s to make a delimited identifier
const processCol = col => `"${sqlString(col).slice(1, -1)}"`

// Smashes the parameters and values together into a series of SQL conditions, ANDed
function composeFilterQuery(filters) {
    return Object.entries(filters)
                 .map(entry => `${processCol(entry[0])} = ${sqlString(entry[1])}`)
                 .join(' AND ')
}

// Replaces the "table" for each layer definition, which defines the query, with the original
// value wrapped in a further filtering query
function applyFilterQuery(xmlJson, filterQuery) {
    xmlJson.Map.Layer.forEach((layer) => {
        // Get the <Datasource><Parameter name="table"> element, which contains the default query
        const queryObj = layer.Datasource[0].Parameter.filter(p => p.$.name === 'table')[0]

        // Add the filters onto it
        const query = `SELECT * FROM ${queryObj._} WHERE ${filterQuery}`

        // Set the new query as the 'table' for the layer
        queryObj._ = `(${query}) as m`
    })
    return xmlJson
}

async function addParamFilters(xmlString, filters) {
    const xmlJson = await parsePromise(xmlString)
    const filterQuery = composeFilterQuery(filters)
    const filteredJson = applyFilterQuery(xmlJson, filterQuery)
    return xmlBuilder.buildObject(filteredJson)
}

module.exports = addParamFilters