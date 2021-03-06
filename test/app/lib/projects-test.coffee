{shallow, set} = require 'fnuc'

describe 'projects', ->

    c = p = null

    beforeEach ->
        p =
            projects:      spy -> [{projectId:'TTN0001', clientId:'TTN', title:'Möten'}]
            saveproject:   spy (p) -> set shallow(p), '_id', 'saved'
            deleteproject: spy (c) ->
        c = require('../../../app/lib/projects') p

    describe 'init', ->

        it 'initialises from persistence', ->
            eql c.init(),
                input: null
                state: null
                editId: null
                projects: [{projectId:'TTN0001', clientId:'TTN', title:'Möten'}]

    describe 'addproject', ->

        describe 'for a new project', ->

            it 'saves the client and appends to the model', ->
                m1 = {projects:[]}
                m2 = c.addproject m1, {projectId:'NEW0123', clientId:'NEW', title:'New project'}
                eql m2,
                    projects:[{_id:'saved', clientId:'NEW', projectId:'NEW0123', title:'New project'}]


        describe 'for an existing project', ->

            it 'saves the project and updates the model', ->
                m1 = {projects:[{_id:'saved', clientId:'NEW', projectId:'NEW0123', title:'New client'}]}
                m2 = c.addproject m1, {_id:'saved', clientId:'NEW', projectId:'NEW0123', title:'Changed'}
                eql m2, {projects:[{_id:'saved', clientId:'NEW', projectId:'NEW0123', title:'Changed'}]}
                eql p.saveproject.args.length, 1

    describe 'setnew', ->

        it 'sets/parses a new client as input', ->
            m1 = {projects:[], state:''}
            m2 = c.setnew m1, 'abc0123 Some Title'
            eql m2, {projects:[], input:{clientId:'ABC', projectId:'ABC0123', title:'Some Title'}, state:'valid'}

        it 'preserves _id', ->
            m1 = {projects:[], input:{_id:'id123'}, state:''}
            m2 = c.setnew m1, 'abc0123 Some Title'
            eql m2, {projects:[], input:{clientId:'ABC', projectId:'ABC0123', title:'Some Title', _id:'id123'}, state:'valid'}

        it 'sets invalid for too short input', ->
            m1 = {projects:[], state:''}
            m2 = c.setnew m1, 'abc0123 '
            eql m2, {projects:[], input:{clientId:'ABC', projectId:'ABC0123', title:''}, state:'nullval'}

        it 'sets invalid for a bad input', ->
            m1 = {projects:[], state:''}
            m2 = c.setnew m1, ''
            eql m2, {projects:[], input:{clientId:undefined, projectId:undefined, title:undefined}, state:'nullval'}

        it 'sets invalid for too long input', ->
            m1 = {projects:[], state:''}
            m2 = c.setnew m1, 'ABCDEF1 blaha'
            eql m2, {projects:[], input:{clientId:undefined, projectId:undefined, title:undefined}, state:'nullval'}

        it 'sets invalid for existing', ->
            m1 = {projects:[{projectId:'ABC0001'}], state:''}
            m2 = c.setnew m1, 'ABC1 Fin grej'
            eql m2,
                projects:[{projectId:'ABC0001'}], input:{projectId:'ABC0001', clientId:'ABC', title:'Fin grej'}
                state:'exists'

        it 'not set invalid for existing if editId', ->
            m1 = {projects:[{projectId:'ABC0001'}], state:'', editId:'ABC0001'}
            m2 = c.setnew m1, 'ABC1 Fin grej'
            eql m2,
                editId: 'ABC0001'
                projects:[{projectId:'ABC0001'}], input:{projectId:'ABC0001', clientId:'ABC', title:'Fin grej'}
                state:'valid'

    describe 'update', ->

        it 'adds new', ->
            m1 = {projects:[], state:''}
            m2 = c.setnew m1, 'abc0123 ABra Cadabra'
            m3 = c.update m2, m2.input
            eql m3.projects, [{clientId:'ABC', projectId:'ABC0123', title:'ABra Cadabra'}]

        it 'replaces equal', ->
            m1 = {projects:[{projectId:'TTN001'},{projectId:'ABC0123', title:'panda'}]}
            m2 = c.setnew m1, 'abc0123 ABra Cadabra'
            m3 = c.update m2, m2.input
            eql m3.projects, [{clientId:'ABC', projectId:'ABC0123', title:'ABra Cadabra'},{projectId:'TTN001'}]

    describe 'save', ->

        it 'saves the current input', ->
            m1 = {projects:[], state:''}
            m2 = c.setnew m1, 'abc0123 ABra Cadabra'
            m3 = c.save m2
            eql m3, {input:null, projects:[{_id:'saved', clientId:'ABC', projectId:'ABC0123', title:'ABra Cadabra'}], state:'saved'}

        it 'wont save invalid', ->
            m1 = {projects:[], state:''}
            m2 = c.setnew m1, 'a ABra Cadabra'
            m3 = c.save m2
            eql m3, null

    describe 'decorate', ->

        it 'adds on _project on an entry', ->
            m =
                projects:[pr = {_id:'saved', projectId:'NEW0001', title:'New project'}]
            e = c.decorate(m) {clientId:'NEW', projectId:'NEW0001'}
            eql e, {clientId:'NEW', projectId:'NEW0001', _project:pr}

    describe 'edit', ->

        it 'for existing it begins editing', ->
            m1 = {projects:[{projectId:'TTN001'},{projectId:'ABC0123', title:'panda'}]}
            m2 = c.edit m1, 'ABC0123'
            eql m2,
                projects:[{projectId:'TTN001'},{projectId:'ABC0123', title:'panda'}]
                editId:'ABC0123'
                input:{projectId:'ABC0123', title:'panda'}
