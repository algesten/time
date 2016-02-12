{shallow, set} = require 'fnuc'

describe 'clients', ->

    c = p = null

    beforeEach ->
        p =
            clients:    spy -> [{clientId:'TTN', title:'TT Nyhetsbyrån'}]
            saveclient: spy (c) -> set shallow(c), '_id', 'saved'
        c = require('../../../app/lib/clients') p

    describe 'init', ->

        it 'initialises from persistence', ->
            eql c.init(),
                clients:  [{clientId:'TTN', title:'TT Nyhetsbyrån'}]

    describe 'addclient', ->

        describe 'for a new client', ->

            it 'saves the client and appends to the model', ->
                m1 = {clients:[]}
                m2 = c.addclient m1, {clientId:'NEW', title:'New client'}
                eql m2, {clients:[{_id:'saved', clientId:'NEW', title:'New client'}]}

        describe 'for an existing client', ->

            it 'saves the client and updates the model', ->
                m1 = {clients:[{_id:'saved', clientId:'NEW', title:'New client'}]}
                m2 = c.addclient m1, {_id:'saved', clientId:'NEW', title:'Changed'}
                eql m2, {clients:[{_id:'saved', clientId:'NEW', title:'Changed'}]}
                eql p.saveclient.args.length, 1

    describe 'decorate', ->

        it 'adds on _client on an entry', ->
            m =
                clients:[cl = {_id:'saved', clientId:'NEW', title:'New client'}]
            e = c.decorate m, {clientId:'NEW', projectId:'NEW0001'}
            eql e, {clientId:'NEW', projectId:'NEW0001', _client:cl}
