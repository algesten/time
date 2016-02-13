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
                input: null
                state: null
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

    describe 'setnew', ->

        it 'sets/parses a new client as input', ->
            m1 = {clients:[], state:''}
            m2 = c.setnew m1, 'abc ABra Cadabra'
            eql m2, {clients:[], input:{clientId:'ABC', title:'ABra Cadabra'}, state:'valid'}

        it 'sets invalid for a bad input', ->
            m1 = {clients:[], state:''}
            m2 = c.setnew m1, 'AB Cadabra'
            eql m2, {clients:[], input:{clientId:undefined, title:undefined}, state:'invalid'}

    describe 'update', ->

        it 'adds new', ->
            m1 = {clients:[], state:''}
            m2 = c.setnew m1, 'abc ABra Cadabra'
            m3 = c.update m2, m2.input
            eql m3.clients, [{clientId:'ABC', title:'ABra Cadabra'}]

        it 'replaces equal', ->
            m1 = {clients:[{clientId:'TTN'},{clientId:'ABC', title:'panda'}]}
            m2 = c.setnew m1, 'abc ABra Cadabra'
            m3 = c.update m2, m2.input
            eql m3.clients, [{clientId:'TTN'},{clientId:'ABC', title:'ABra Cadabra'}]

    describe 'save', ->

        it 'saves the current input', ->
            m1 = {clients:[], state:''}
            m2 = c.setnew m1, 'abc ABra Cadabra'
            m3 = c.save m2
            eql m3, {input:null, clients:[{_id:'saved', clientId:'ABC', title:'ABra Cadabra'}], state:'saved'}

        it 'wont save invalid', ->
            m1 = {clients:[], state:''}
            m2 = c.setnew m1, 'a ABra Cadabra'
            m3 = c.save m2
            eql m3, null

    describe 'decorate', ->

        it 'adds on _client on an entry', ->
            m =
                clients:[cl = {_id:'saved', clientId:'NEW', title:'New client'}]
            e = c.decorate m, {clientId:'NEW', projectId:'NEW0001'}
            eql e, {clientId:'NEW', projectId:'NEW0001', _client:cl}
