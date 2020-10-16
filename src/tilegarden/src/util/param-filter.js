/**
 * Defines a function that accepts a config XML converted to an object and returns the same
 * with col=value filters applied to each layer's "table" value.
 */

const sqlString = require('sql-escape-string')

// Helper function to escape col but replace outer '-s with "-s to make a delimited identifier
const processCol = (col) => `"${sqlString(col).slice(1, -1)}"`

// Combine parameters and values into a series of SQL conditions, ANDed
function composeFilterQuery(filters) {
    return Object.entries(filters)
        .map((entry) => `${processCol(entry[0])} = ${sqlString(entry[1])}`)
        .join(' AND ')
}

// Replace the "table" for each layer definition (which can be a table name or a SELECT query)
// with the original value wrapped in a further filtering query
function applyFilterQuery(xmlJson, filterQuery) {
    xmlJson.Map.Layer.forEach((layer) => {
        // Get the <Datasource><Parameter name="table"> element, which contains the default query
        const queryObj = layer.Datasource[0].Parameter.filter((p) => p.$.name === 'table')[0]

        // Add the filters onto it
        const query = `SELECT * FROM ${queryObj._} WHERE ${filterQuery}`

        // Set the new query as the 'table' for the layer
        queryObj._ = `(${query}) as m`
    })
    return xmlJson
}

function addParamFilters(xmlJsObj, filters) {
    const filterQuery = composeFilterQuery(filters)
    return applyFilterQuery(xmlJsObj, filterQuery)
}

module.exports = addParamFilters
