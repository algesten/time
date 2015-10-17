{mixin} = require 'fnuc'

parse = require '../../../app/lib/parse'

today = do ->
    cur = -> (new Date()).toISOString()[0...10]
    -> new Date "#{cur()}Z"

describe 'parse', ->

    describe 'without enough input', ->

        base = {
            clientId: undefined
            date: null
            time: null
            entryId: undefined
            orig: ''
            projectId: ''
            title: ''
            userId: undefined
        }

        [['', mixin base, mixin base]
         ['t', mixin base, date:today()]
         ['t meeting', mixin base, title:'meeting', date:today()]
         ['t meeting ttmet', mixin base, title:'meeting', projectId:'ttmet', date:today()]
        ].forEach ([i,cmp]) ->
            cmp = mixin cmp, orig:i
            it "returns partial objects for '#{i}'", ->
                p = parse({}, i)
                delete p.modified
                eql p, cmp

    it 'returns an object with parsed values', ->
        p = parse({}, '150601 important meeting ttmet 3h')
        delete p.modified
        eql p, {
            clientId: undefined
            date: new Date("2015-06-01Z")
            time: 10800
            entryId: undefined
            orig: '150601 important meeting ttmet 3h'
            projectId: 'ttmet'
            title: 'important meeting'
            userId: undefined
        }

    it 'copies some values from model', ->
        p = parse({editId:'123', userId:'ture', projects:{ttmet:{clientId:'tt'}}},
            '150601 meeting ttmet 3h')
        delete p.modified
        eql p, {
            clientId: 'tt'
            date: new Date("2015-06-01Z")
            time: 10800
            entryId: '123'
            orig: '150601 meeting ttmet 3h'
            projectId: 'ttmet'
            title: 'meeting'
            userId: 'ture'
        }
