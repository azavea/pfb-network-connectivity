/* Creates and exports a logger that logs to console and prepends a timestamp.
 * Default log level is 'info', switching to 'debug' if DEBUG is true in the environment.
 */

const { createLogger, format, transports } = require('winston')

const logger = createLogger({
    level: process.env.DEBUG ? 'debug' : 'info',
    format: format.combine(
        format.timestamp(),
        format.printf(({ timestamp, level, message }) => `${level}:\t${timestamp} ${message}`),
    ),
    transports: [new transports.Console()],
})

module.exports = logger
