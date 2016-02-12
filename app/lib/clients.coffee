{converge, indexfn, eq, get, nth, pipe, evolve, firstfn, mixin,
always, iif, split, pick, I} = require 'fnuc'
{append, adjust, remove}     = require './immut'
{tostate, stateis, validate} = require './state'
parseclient  = require './parseclient'
hasnullvalue = require './hasnullvalues'

spc = split ' '

module.exports = (persist) ->

    # :: * -> model
    init = do ->
        doinit = (clients) -> {clients}
        fn = pipe persist.clients, doinit
        -> fn() # no arguments

    # :: string -> client -> boolean
    _eq = (prop) -> (id) -> pipe(get(prop), eq(id))
    eqclient  = _eq 'clientId'

    # :: entries -> boolean
    isvalid = do ->
        props = spc 'clientId title'
        check = iif pipe(pick(props), hasnullvalue), always(false), always(true)
        pipe get('input'), check

    # :: (model, string, string) -> entries
    setnew = do ->
        doset = (model, clientId, title) -> mixin model, {input:{clientId, title}}
        fn = pipe doset, validate(isvalid)
        (model, clientId, title) -> fn model, parseclient(clientId), title

    # :: model, client -> model
    update = (model, client) ->
        idx = indexfn model.clients, eqclient(client.clientId)
        evolve model,
            clients: (if idx < 0 then append else adjust(idx))(client)

    # entries -> entries
    unedit = evolve {editId:always(null), input:always(null)}

    # :: model -> model
    save = do ->
        saveinput = pipe get('input'), persist.saveclient
        dosave = converge I, saveinput, pipe update, unedit
        stateis('valid') pipe tostate('saving'), dosave, tostate('saved')

    # :: (model, client) -> model
    addclient = converge nth(0), pipe(nth(1), persist.saveclient), (model, client) ->
        idx = indexfn model.clients, eqclient(client.clientId)
        evolve model,
            clients: (if idx < 0 then append else adjust(idx)) client

    # :: (model, entry) -> entry
    decorate = (model, entry) ->
        client  = firstfn model.clients, eqclient(entry.clientId)
        mixin entry, {_client:client}

    {init, addclient, setnew, update, save, decorate}
