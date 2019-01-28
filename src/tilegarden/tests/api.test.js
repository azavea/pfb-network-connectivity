const rewire = require('rewire')
const api = rewire('../src/api'),
    processCoords = api.__get__('processCoords')

describe('processCoords', () => {
    test('properly parses properly formatted coords', () => {
        const req = {
            pathParameters: {
                x: '2385',
                y: '3103.png',
                z: '13'
            }
        }
        expect(processCoords(req)).toEqual({
            x: 2385,
            y: 3103,
            z: 13
        })
    })

    test('parses extensions other than png', () => {
        const req = {
            pathParameters: {
                x: '2385',
                y: '3103.jpg',
                z: '13'
            }
        }
        const req2 = {
            pathParameters: {
                x: '2385',
                y: '3103.pdf',
                z: '13'
            }
        }
        expect(processCoords(req)).toEqual({
            x: 2385,
            y: 3103,
            z: 13
        })
        expect(processCoords(req2)).toEqual({
            x: 2385,
            y: 3103,
            z: 13
        })
    })

    test('properly parses coords with no file extension', () => {
        const req = {
            pathParameters: {
                x: '2385',
                y: '3103',
                z: '13'
            }
        }
        expect(processCoords(req)).toEqual({
            x: 2385,
            y: 3103,
            z: 13
        })
    })

    test('throws an error for non-numeral coords', () => {
        const req = {
            pathParameters: {
                x: 'eggs',
                y: 'bacon',
                z: 'orange_juice'
            }
        }
        expect(() => processCoords(req)).toThrow()
    })
})

