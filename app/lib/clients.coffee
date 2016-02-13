{converge, indexfn, eq, get, nth, pipe, evolve, firstfn, mixin,
always, iif, split, pick, I, match, aand} = require 'fnuc'
{append, adjust, remove}     = require './immut'
{tostate, stateis, validate} = require './state'
parseclient  = require './parseclient'
hasnullvalue = require './hasnullvalues'

spc = split ' '

module.exports = (persist) ->

    # :: * -> model
    init = do ->
        doinit = (clients) -> {clients, state:null, input:null}
        fn = pipe persist.clients, doinit
        -> fn() # no arguments

    # :: string -> client -> boolean
    _eq = (prop) -> (id) -> pipe(get(prop), eq(id))
    eqclient  = _eq 'clientId'

    # :: model -> boolean
    isnotvalid = do ->
        props = spc 'clientId title'
        notnull = pipe get('input'), pick(props), iif hasnullvalue, always('nullval'), always(null)
        notexists = (model) ->
            'exists' if indexfn(model.clients, eqclient(model.input.clientId)) >= 0
        converge notexists, notnull, (a, b) -> a ? b

    # :: (model, string, string) -> model
    setnew = do ->
        doset = (model, clientId, title) -> mixin model, {input:{clientId, title}}
        splitter = pipe match(/^\s*(\w{3})(?:\s+(.*?))?\s*$/), iif I, I, always([])
        fn = pipe doset, validate(isnotvalid)
        (model, txt) ->
            [_, idpart, title] = splitter txt
            fn model, parseclient(idpart), title

    # :: model, client -> model
    update = (model, client) ->
        idx = indexfn model.clients, eqclient(client.clientId)
        evolve model,
            clients: (if idx < 0 then append else adjust(idx))(client)

    # model -> model
    unedit = evolve {input:always(null), state:always(null)}

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

    # :: (model) -> (entry) -> entry
    decorate = (model) -> (entry) ->
        client  = firstfn model.clients, eqclient(entry.clientId)
        mixin entry, {_client:client}

    {init, addclient, setnew, update, save, unedit, decorate}
