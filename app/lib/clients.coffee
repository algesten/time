{converge, indexfn, eq, get, nth, pipe, evolve, firstfn, mixin,
always, iif, split, pick, I, match, aand, sort, call, keyval} = require 'fnuc'
{append, adjust, remove}     = require './immut'
{tostate, stateis, validate} = require './state'
parseclient  = require './parseclient'
hasnullvalue = require './hasnullvalues'

spc = split ' '

module.exports = (persist) ->

    # :: * -> model
    init = do ->
        doinit = (clients) -> {clients, state:null, input:null, editId:null}
        fn = pipe persist.clients, doinit
        -> fn() # no arguments

    # :: string -> client -> boolean
    _eq = (prop) -> (id) -> pipe(get(prop), eq(id))
    eqclient  = _eq 'clientId'

    # :: (model) -> boolean
    isedit = (model) -> !!model?.editId

    # :: model -> boolean
    isnotvalid = do ->
        props = spc 'clientId title'
        notnull = pipe get('input'), pick(props), iif hasnullvalue, always('nullval'), always(null)
        doexists = (model) -> indexfn(model.clients, eqclient(model.input.clientId)) >= 0
        notexists = (model) ->
            'exists' if !isedit(model) and doexists(model)
        converge notexists, notnull, (a, b) -> a ? b

    mkeyval = (k, v) -> if v then keyval(k,v) else null

    # :: (model, string, string) -> model
    setnew = do ->
        doset = (model, clientId, title) ->
            mixin model, input:mixin({clientId, title}, mkeyval('_id',model?.input?._id))
        splitter = pipe match(/^\s*(\w{3})(?:\s+(.*?))?\s*$/), iif I, I, always([])
        fn = pipe doset, validate(isnotvalid)
        (model, txt) ->
            [_, idpart, title] = splitter txt
            fn model, parseclient(idpart), title

    # :: model, client -> model
    update = (model, client) ->
        idx = indexfn model.clients, eqclient(client.clientId)
        sorted = sort (c1, c2) -> c1.clientId.localeCompare c2.clientId
        evolve model,
            clients: pipe (if idx < 0 then append else adjust(idx))(client), sorted

    # :: (model, string) -> model
    edit = do ->
        finder = pipe nth(1), eqclient, firstfn
        clientsof = pipe nth(0), get('clients')
        toinput  = (client) -> {editId:client?.clientId, input:client}
        getinput = converge finder, clientsof, pipe call, toinput
        converge I, getinput, pipe mixin, iif get('input'), tostate('valid'), tostate('')

    # model -> model
    unedit = evolve {input:always(null), state:always(null), editId:always(null)}

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

    # :: model, client -> model
    erase = (model, client) ->
        idx = indexfn model.clients, eqclient(client.clientId)
        evolve model, {clients:remove(idx)}

    # :: (model, client) -> model
    delet = do ->
        eraseif = iif nth(2), erase, nth(0)
        converge nth(0), nth(1), pipe(nth(1), persist.deleteclient), pipe eraseif, unedit

    {init, addclient, setnew, update, save, edit, decorate, erase, delet}
