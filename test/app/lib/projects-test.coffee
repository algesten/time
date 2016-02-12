{shallow, set} = require 'fnuc'

describe 'projects', ->

    c = p = null

    beforeEach ->
        p =
            clients:     spy -> [{clientId:'TTN', title:'TT Nyhetsbyrån'}]
            saveproject: spy (p) -> set shallow(p), '_id', 'saved'
            projects:    spy -> [{projectId:'TTN0001', clientId:'TTN', title:'Möten'}]
        c = require('../../../app/lib/projects') p

    describe 'init', ->

        it 'initialises from persistence', ->
            eql c.init(),
                projects: [{projectId:'TTN0001', clientId:'TTN', title:'Möten'}]

    describe 'addproject', ->

        describe 'for a new project', ->

            it 'saves the client and appends to the model', ->
                m1 = {projects:[]}
                m2 = c.addproject m1, {projectId:'NEW0123', clientId:'NEW', title:'New project'}
                eql m2, {projects:[{_id:'saved', clientId:'NEW', projectId:'NEW0123', title:'New project'}]}

        describe 'for an existing project', ->

            it 'saves the project and updates the model', ->
                m1 = {projects:[{_id:'saved', clientId:'NEW', projectId:'NEW0123', title:'New client'}]}
                m2 = c.addproject m1, {_id:'saved', clientId:'NEW', projectId:'NEW0123', title:'Changed'}
                eql m2, {projects:[{_id:'saved', clientId:'NEW', projectId:'NEW0123', title:'Changed'}]}
                eql p.saveproject.args.length, 1

    describe 'decorate', ->

        it 'adds on _project on an entry', ->
            m =
                projects:[pr = {_id:'saved', projectId:'NEW0001', title:'New project'}]
            e = c.decorate m, {clientId:'NEW', projectId:'NEW0001'}
            eql e, {clientId:'NEW', projectId:'NEW0001', _project:pr}
