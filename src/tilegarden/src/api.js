/**
 * Entrypoint for APIGateway
 */

const APIBuilder = require('claudia-api-builder')

const { imageTile, createMap } = require('./tiler')
const HTTPError = require('./util/error-builder')

const IMAGE_HEADERS = {
    'Content-Type': 'image/png',
}

const HTML_RESPONSE = { success: { contentType: 'text/html' } }

// Converts a req object to a set of coordinates
const processCoords = (req) => {
    // Handle url params
    const z = Number(req.pathParams.z)
    const x = Number(req.pathParams.x)

    // strip .png off of y if necessary
    const preY = req.pathParams.y
    const y = Number(preY.substr(0, preY.lastIndexOf('.')) || preY)

    // Check type of coords
    /* eslint-disable-next-line no-restricted-globals */
    if (isNaN(x) || isNaN(y) || isNaN(z)) {
        throw HTTPError('Error: Coordinate values must be numbers!', 400)
    }
    return { z, x, y }
}

// Returns a properly formatted list of layers
// or an empty list if there are none
const processLayers = (req) => {
    if (req.queryString.layers) return JSON.parse(req.queryString.layers)
    else if (req.queryString.layer || req.queryString.filter || req.queryString.filters) {
        /* eslint-disable-next-line quotes */
        throw HTTPError("Invalid argument, did you mean '&layers='?", 400)
    }

    return []
}

// Parses out the configuration specifications
const processConfig = req => ({
    s3bucket: req.queryString.s3bucket,
    config: req.queryString.config,
})

// Create new lambda API
const api = new APIBuilder()

// Handles error by returning an API response object
const handleError = (e) => {
    /* eslint-disable-next-line no-console */
    console.error(e)
    return new APIBuilder.ApiResponse(
        { message: e.message || e.toString() },
        { 'Content-Type': 'application/json' },
        e.http_code || 500,
    )
}

// Get tile for some zxy bounds
api.get(
    '/tile/{z}/{x}/{y}',
    (req) => {
        try {
            const { z, x, y } = processCoords(req)
            const layers = processLayers(req)
            const configOptions = processConfig(req)

            return imageTile(createMap(z, x, y, layers, configOptions))
                .then(img => new APIBuilder.ApiResponse(img, IMAGE_HEADERS, 200))
                .catch(handleError)
        } catch (e) {
            return handleError(e)
        }
    },
    { success: { contentHandling: 'CONVERT_TO_BINARY' } },
)

api.get(
    '/',
    /* eslint-disable max-len */
    () => `
        <html>
            <head>
            <title>Tilegarden tiler</title>
            </head>
            <body>
                <h2>Usage:</h2>
                <ul>
                    <li>Render raster tile at zoom/x/y: <code>/tile/{z}/{x}/{y}.png</code></li>
                </ul>
            </body>
        </html>
    `,
    /* eslint-enable max-len */
    HTML_RESPONSE,
)

// 404 response
// This works in production but breaks the dev server just by existing
api.get(
    '/{wildcard+}',
    () => new APIBuilder.ApiResponse(
        { message: '404: Invalid path.' },
        { 'Content-Type': 'application/json' },
        404,
    ),
)

// not es6-ic, but necessary for claudia to find the index
module.exports = api
