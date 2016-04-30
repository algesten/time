{each} = require 'fnuc'

parsetime = require '../../../app/lib/parsetime'

describe 'parsetime', ->

    locales = [
        n: 'default'
        tests: [
            [['', 'h'],                                    'as null',  null]
            [['1',       '1h'],                           'one hour',  3600]
            [['0:1',     '1m'],                         'one minute',    60]
            [['0:0:1',   '1s'],                         'one second',     1]
            [['1:0:0:0', '1d'],                            'one day', 86400]
            [['1.30',  '1:30', '1.3'],         'one and a half hour',  5400]
            [['1:1', '1h1', '1h1m', '1m1h'],            '61 minutes',  3660]
            [['1:1:1', '1h1m1s', '1s1m1h', '1m1s1h'], '3661 seconds',  3661]
        ]
    ]

    each locales, (l) -> describe "in #{l.n} locale", -> each l.tests, (t) -> each t[0], (v) ->
        it "parses '#{v}' as #{t[1]}", ->
            eql parsetime(v), t[2]
