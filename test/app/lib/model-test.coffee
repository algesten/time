{shallow, set} = require 'fnuc'

describe 'model', ->

    m = p = u = null

    start = new Date('2015-10-01Z')
    stop = new Date('2015-10-20Z')

    entry =
        billable: undefined
        clientId: undefined
        date: new Date('2015-10-11Z')
        entryId: 'ent1'
        orig: '151011 important meeting 3h ttmot'
        projectId: 'ttmot'
        time: 10800
        title: 'important meeting'
        userId: 'ture'

    model =
        clients: []
        editId: null
        entries: []
        input: null
        projects: []
        state: ""
        userId: "ture"

    withentry =
        clients: []
        editId: null
        entries: [entry]
        input: null
        projects: []
        state: ""
        userId: "ture"

    beforeEach ->
        p =
            load: spy -> {userId:'ture', entries:[]}
            save: spy (e) -> set shallow(e), 'entryId', 'saved'
            clients:  spy -> []
            projects: spy -> []
            saveproject: spy ->
        u = spy ->
        m = require('../../../app/lib/model') p, u

    describe 'load', ->

        it 'initialises from persistence', ->
            eql m.load(start, stop),
                clients: []
                editId: null
                entries: []
                input: null
                projects: []
                state: ""
                userId: "ture"
            eql p.load.args.length, 1
            eql p.load.args[0], [start, stop]
            eql u.args.length, 1
            eql u.args[0], ['model']

    describe 'setnew', ->

        it 'parses the string to model.input', ->
            model2 = m.setnew(model, '151011 important meeting ttmot 3h')
            delete model2.input.modified
            eql model2,
                clients: []
                editId: null
                entries: []
                input:
                    billable: undefined
                    clientId: undefined
                    date: new Date('2015-10-11Z')
                    entryId: null
                    orig: '151011 important meeting ttmot 3h'
                    projectId: 'ttmot'
                    time: 10800
                    title: 'important meeting'
                    userId: 'ture'
                projects: []
                state: "valid"
                userId: "ture"

    describe 'edit', ->

        it 'sets a valid input/editId', ->
            model2 = m.edit withentry, 'ent1'
            eql model2.editId, 'ent1'
            eql model2.input.entryId, 'ent1'

        it 'doesnt set an invalid input/editId', ->
            model2 = m.edit withentry, 'entx'
            eql model2.editId, null
            eql model2.input, null

    describe 'save', ->

        it 'saves the currently edited entry', ->
            model2 = m.setnew model, '151011 important meeting ttmot 3h'
            model3 = m.save model2
            eql model3.entries.length, 1
            eql model3.entries[0].entryId, 'saved'
