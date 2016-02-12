{shallow, set} = require 'fnuc'

describe 'projects', ->

    c = p = null

    beforeEach ->
        p =
            projects:    spy -> [{projectId:'TTN0001', clientId:'TTN', title:'Möten'}]
            saveproject: spy (p) -> set shallow(p), '_id', 'saved'
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

    describe 'setnew', ->

        it 'sets/parses a new client as input', ->
            m1 = {projects:[], state:''}
            m2 = c.setnew m1, 'abc0123', 'ABra Cadabra'
            eql m2, {projects:[], input:{clientId:'ABC', projectId:'ABC0123', title:'ABra Cadabra'}, state:'valid'}

        it 'sets invalid for a bad input', ->
            m1 = {projects:[], state:''}
            m2 = c.setnew m1, '', 'ABra Cadabra'
            eql m2, {projects:[], input:{clientId:undefined, projectId:undefined, title:'ABra Cadabra'}, state:'invalid'}

    describe 'update', ->

        it 'adds new', ->
            m1 = {projects:[], state:''}
            m2 = c.setnew m1, 'abc0123', 'ABra Cadabra'
            m3 = c.update m2, m2.input
            eql m3.projects, [{clientId:'ABC', projectId:'ABC0123', title:'ABra Cadabra'}]

        it 'replaces equal', ->
            m1 = {projects:[{projectId:'TTN001'},{projectId:'ABC0123', title:'panda'}]}
            m2 = c.setnew m1, 'abc0123', 'ABra Cadabra'
            m3 = c.update m2, m2.input
            eql m3.projects, [{projectId:'TTN001'},{clientId:'ABC', projectId:'ABC0123', title:'ABra Cadabra'}]

    describe 'save', ->

        it 'saves the current input', ->
            m1 = {projects:[], state:''}
            m2 = c.setnew m1, 'abc0123', 'ABra Cadabra'
            m3 = c.save m2
            eql m3, {input:null, projects:[{_id:'saved', clientId:'ABC', projectId:'ABC0123', title:'ABra Cadabra'}], state:'saved'}

        it 'wont save invalid', ->
            m1 = {projects:[], state:''}
            m2 = c.setnew m1, 'a', 'ABra Cadabra'
            m3 = c.save m2
            eql m3, null

    describe 'decorate', ->

        it 'adds on _project on an entry', ->
            m =
                projects:[pr = {_id:'saved', projectId:'NEW0001', title:'New project'}]
            e = c.decorate m, {clientId:'NEW', projectId:'NEW0001'}
            eql e, {clientId:'NEW', projectId:'NEW0001', _project:pr}
