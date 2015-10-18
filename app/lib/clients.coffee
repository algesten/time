{converge, indexfn, eq, get, nth, pipe} = require 'fnuc'

module.exports = (persist) ->

    # :: * -> clients
    init = do ->
        doinit = (clients, projects) -> {clients, projects}
        fn = converge persist.clients, persist.projects, doinit
        -> fn() # no arguments

    # :: string -> client -> boolean
    eqclient = (clientId) -> pipe(get('clientId'), eq(clientId))

    # :: (model, client) -> model
    addclient = converge nth(0), pipe(nth(1), persist.saveclient), (model, client) ->
        idx = indexfn model.clients, eqclient(client.clientId)
        evolve model,
            clients: (if idx < 0 then append else adjust(idx)) client

    {init}
