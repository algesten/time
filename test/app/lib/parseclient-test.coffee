{each} = require 'fnuc'

describe 'parseclient', ->

    parseclient = require('../../../app/lib/parseclient')

    tests = [
        ['undefined', undefined, undefined]
        ['empty string', '', undefined]
        ['too short', 'tt', undefined]
        ['trailing space', 'ttn ', 'TTN']
        ['initial space', ' ttn', 'TTN']
        ['project numbers', 'ttn123', 'TTN']
    ]

    each tests, (t) -> it "handles #{t[0]}", ->
        eql parseclient(t[1]), t[2]
