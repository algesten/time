{mixin} = require 'fnuc'

parse = require '../../../app/lib/parse'

today = do ->
    cur = -> (new Date()).toISOString()[0...10]
    -> (new Date "#{cur()}Z").toISOString()

describe 'parse', ->

    describe 'without enough input', ->

        base = {
            clientId: undefined
            date: undefined
            time: null
            entryId: undefined
            orig: ''
            projectId: undefined
            title: ''
            userId: undefined
        }

        [['', mixin base, mixin base]
         ['t', mixin base, date:today()]
         ['t meeting', mixin base, title:'meeting', date:today()]
         ['t meeting ttn1', mixin base, title:'meeting', clientId:'TTN',
             projectId:'TTN0001', date:today()]
        ].forEach ([i,cmp]) ->
            cmp = mixin cmp, orig:i
            it "returns partial objects for '#{i}'", ->
                p = parse({}, i)
                delete p.modified
                eql p, cmp

    it 'returns an object with parsed values', ->
        p = parse({}, '150601 important meeting ttn1 3h')
        delete p.modified
        eql p, {
            clientId: 'TTN'
            date: new Date("2015-06-01Z").toISOString()
            time: 10800
            entryId: undefined
            orig: '150601 important meeting ttn1 3h'
            projectId: 'TTN0001'
            title: 'important meeting'
            userId: undefined
        }

    it 'copies some values from model', ->
        p = parse({editId:'123', userId:'ture', projects:{TTN0001:{clientId:'TTN'}}},
            '150601 meeting ttn1 3h')
        delete p.modified
        eql p, {
            clientId: 'TTN'
            date: new Date("2015-06-01Z").toISOString()
            time: 10800
            entryId: '123'
            orig: '150601 meeting ttn1 3h'
            projectId: 'TTN0001'
            title: 'meeting'
            userId: 'ture'
        }
