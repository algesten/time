{converge, indexfn, eq, get, nth, pipe, evolve, firstfn, mixin} = require 'fnuc'
{append, adjust} = require './immut'

module.exports = (persist) ->

    # :: * -> clients
    init = do ->
        doinit = (clients) -> {clients}
        fn = pipe persist.clients, doinit
        -> fn() # no arguments

    # :: string -> client -> boolean
    _eq = (prop) -> (id) -> pipe(get(prop), eq(id))
    eqclient  = _eq 'clientId'

    # :: (clients, client) -> clients
    addclient = converge nth(0), pipe(nth(1), persist.saveclient), (model, client) ->
        idx = indexfn model.clients, eqclient(client.clientId)
        evolve model,
            clients: (if idx < 0 then append else adjust(idx)) client

    # :: (clients, entry) -> entry
    decorate = (model, entry) ->
        client  = firstfn model.clients, eqclient(entry.clientId)
        mixin entry, {_client:client}

    {init, addclient, decorate}
