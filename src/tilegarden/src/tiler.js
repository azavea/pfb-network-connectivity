/**
 * Module that handles tile creation and other
 * map drawing functionality
 */

/* eslint-disable no-console */

const mapnik = require('mapnik')
const path = require('path')
const aws = require('aws-sdk')

const { promisify } = require('util')
const readFile = promisify(require('fs').readFile)

const addParamFilters = require('./util/param-filter')
const bbox = require('./util/bounding-box')
const HTTPError = require('./util/error-builder')
const logger = require('./util/logger')
const { parseXml, buildXml } = require('./util/xml-tools')

const TILE_HEIGHT = 256
const TILE_WIDTH = 256

const DEFAULT_CONFIG_FILENAME = 'map-config.xml'

// Register plugins
mapnik.register_default_input_plugins()

// If there's a problem with the database, the details of that shouldn't be exposed to the user.
const postgisFilter = (e) => {
    console.error(e)
    if (e.toString().indexOf('Postgis Plugin') > -1) {
        throw HTTPError('Postgis Error', 500)
    }
    throw e
}

/**
 * Based off the config options object, search for a config.xml
 * file and return it as a Promise that evaluates to an XML string.
 * @param options
 * @returns {Promise<any>}
 */
const fetchMapFile = (options) => {
    logger.debug('Loading map config')
    const { s3bucket, config = DEFAULT_CONFIG_FILENAME } = options

    // If an s3 bucket is specified, treat config as an object key and attempt to fetch
    if (s3bucket) {
        return new Promise((resolve, reject) => {
            logger.debug(`Loading map config ${config} from S3 bucket ${s3bucket}`)
            new aws.S3().getObject({
                Bucket: s3bucket,
                Key: config,
            }, (err, data) => {
                logger.debug('Returning map config from S3')
                if (err) reject(err)
                else resolve(data.Body.toString())
            })
        })
    }

    // otherwise, load from the local directory, making sure to add .xml to the file name
    const configName = path.join(
        __dirname,
        `config/${config}${path.extname(config) !== '.xml' ? '.xml' : ''}`,
    )
    logger.debug('Returning local map config')
    return readFile(configName, 'utf-8').catch((err) => {
        if (err.code === 'ENOENT' && config === DEFAULT_CONFIG_FILENAME) {
            /* eslint-disable-next-line no-param-reassign */
            err.message = 'Error: No default configuration. Must provide a config= parameter.'
        }
        throw err
    })
}

/* Substitutes environment variables into a string using a basic regex-driven template syntax.
 *
 * Any occurrence of ${ENV_VAR} will be replaced with the value of that environment variable.
 */
function fillVars(xmlString) {
    return xmlString.replace(
        /\$\{([A-Z0-9_]+)\}/g,
        (_, envName) => `${process.env[envName]}`,
    )
}

/**
 * Creates a map based on configured datasource and style information
 * @param z
 * @param x
 * @param y
 * @returns {Promise<mapnik.Map>}
 */
module.exports.createMap = (z, x, y, filters, configOptions) => {
    logger.debug(`createMap called: ${z}/${x}/${y}`)
    // Create a webmercator map with specified bounds
    const map = new mapnik.Map(TILE_WIDTH, TILE_HEIGHT)
    map.bufferSize = 64

    // Load map specification from xml string
    return fetchMapFile(configOptions)
        .then(fillVars)
        .then(parseXml)
        .then((xmlJsObj) => addParamFilters(xmlJsObj, filters))
        .then(buildXml)
        .then((xml) => new Promise((resolve, reject) => {
            logger.debug('createMap: calling map.FromString')
            map.fromString(xml, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    /* eslint-disable-next-line no-param-reassign */
                    result.extent = bbox(z, x, y, TILE_HEIGHT, result.srs)
                    logger.debug('createMap: resolving promise')
                    resolve(result)
                }
            })
        }))
        .catch(postgisFilter)
}

/**
 * Returns a promise that renders a map tile for a given map coordinate
 * @param z
 * @param x
 * @param y
 * @returns {Promise<any>}
 */
module.exports.imageTile = (map) => {
    logger.debug('imageTile')
    // create mapnik image
    const img = new mapnik.Image(TILE_WIDTH, TILE_HEIGHT)

    // render map to image
    // return asynchronous rendering method as a promise
    return map
        .then((m) => new Promise((resolve, reject) => {
            logger.debug('imageTile: rendering')
            m.render(img, {}, (err, result) => {
                if (err) reject(err)
                else resolve(result)
            })
        }))
        .then((renderedTile) => new Promise((resolve, reject) => {
            logger.debug('imageTile: encoding')
            renderedTile.encode('png', {}, (err, result) => {
                if (err) reject(err)
                else {
                    logger.debug('imageTile: resolving with encoded tile')
                    resolve(result)
                }
            })
        }))
        .catch(postgisFilter)
}
