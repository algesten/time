
describe 'clients', ->

    c = p = null

    beforeEach ->
        p =
            clients:  spy -> [{clientId:'TTN', title:'TT Nyhetsbyrån'}]
            projects: spy -> [{projectId:'TTN0001', clientId:'TTN', title:'Möten'}]
        c = require('../../../app/lib/clients') p

    describe 'init', ->

        it 'initialises from persistence', ->
            eql c.init(),
                clients:  [{clientId:'TTN', title:'TT Nyhetsbyrån'}]
                projects: [{projectId:'TTN0001', clientId:'TTN', title:'Möten'}]
