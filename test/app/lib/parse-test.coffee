
parse = require '../../../app/lib/parse'

describe 'parse', ->

    describe 'returns null until enough input', ->

        ['', 't', 't meeting', 't meeting ttmet'].forEach (i) ->

            it "for '#{i}'", ->
                eql parse({}, i), null

    it 'returns an object with parsed values', ->
        p = parse({}, '150601 important meeting ttmet 3h')
        delete p.modified
        eql p, {
            billable: undefined
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
        p = parse({editId:'123', userId:'ture', projects:{ttmet:{billable:true,clientId:'tt'}}},
            '150601 meeting ttmet 3h')
        delete p.modified
        eql p, {
            billable: true
            clientId: 'tt'
            date: new Date("2015-06-01Z")
            time: 10800
            entryId: '123'
            orig: '150601 meeting ttmet 3h'
            projectId: 'ttmet'
            title: 'meeting'
            userId: 'ture'
        }
