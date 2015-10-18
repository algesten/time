{shallow, set} = require 'fnuc'

describe 'clients', ->

    c = p = null

    beforeEach ->
        p =
            clients:    spy -> [{clientId:'TTN', title:'TT Nyhetsbyrån'}]
            saveclient: spy (c) -> set shallow(c), '_id', 'saved'
            projects:   spy -> [{projectId:'TTN0001', clientId:'TTN', title:'Möten'}]
        c = require('../../../app/lib/clients') p

    describe 'init', ->

        it 'initialises from persistence', ->
            eql c.init(),
                clients:  [{clientId:'TTN', title:'TT Nyhetsbyrån'}]
                projects: [{projectId:'TTN0001', clientId:'TTN', title:'Möten'}]

    describe 'addclient', ->

        describe 'for a new client', ->

            it 'saves the client and appends to the model', ->
                m1 = {clients:[], projects:[]}
                m2 = c.addclient m1, {clientId:'NEW', title:'New client'}
                eql m2, {clients:[{_id:'saved', clientId:'NEW', title:'New client'}], projects:[]}

        describe 'for an existing client', ->

            it 'saves the client and updates the model', ->
                m1 = {clients:[{_id:'saved', clientId:'NEW', title:'New client'}], projects:[]}
                m2 = c.addclient m1, {_id:'saved', clientId:'NEW', title:'Changed'}
                eql m2, {clients:[{_id:'saved', clientId:'NEW', title:'Changed'}], projects:[]}
                eql p.saveclient.args.length, 1

    describe 'decorate', ->

        it 'adds on _client/_project on an entry', ->
            m =
                clients:[cl = {_id:'saved', clientId:'NEW', title:'New client'}]
                projects:[pr = {_id:'saved', projectId:'NEW0001', title:'New project'}]
            e = c.decorate m, {clientId:'NEW', projectId:'NEW0001'}
            eql e, {clientId:'NEW', projectId:'NEW0001', _client:cl, _project:pr}
