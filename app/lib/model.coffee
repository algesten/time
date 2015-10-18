{nth, iif, sort, evolve, converge, I, always, tap, sort, pipe, get,
mixin, firstfn, eq, indexfn, index, values, split, pick} = require 'fnuc'
{append, adjust} = require './immut'

revtime = do ->
    gettimeprop = (p) -> (o) -> o[p]?.getTime?()
    timof   = gettimeprop 'time'
    modof   = gettimeprop 'modified'
    sort (o1, o2) -> if (r = timof(o1) - timof(o2)) then r else modof(o1) - modof(o2)

# model:
#   - userId       String user id
#   - entries      Array of entry
#   - state        model state "saving", "saved"
#   - input        entry of current input
#   - editId       String id of entry being edited

parse = require './parse'

spc = split ' '
hasnullvalue = (o) -> index(values(o), null) >= 0

module.exports = (persist) ->

    # :: string -> model -> model
    tostate = (state) -> evolve {state:always(state)}

    # :: model -> <persist> -> (saved) entry
    savenew = pipe get('input'), persist.save

    # :: model -> boolean
    isvalid = do ->
        props = spc 'date title projectId time'
        check = iif pipe(pick(props), hasnullvalue), always(false), always(true)
        pipe get('input'), check

    # :: string -> entry -> boolean
    eqentry = (entryId) -> pipe(get('entryId'), eq(entryId))

    # :: model -> model with update state
    validate  = iif isvalid, tostate('valid'), tostate('invalid')

    # :: (model, string) -> model
    setnew = do ->
        doset = (model, entry) -> mixin model, {input:entry}
        converge nth(0), parse, pipe(doset, validate)

    # :: model -> model
    dosave = converge I, savenew, (model, entry) ->
        idx = indexfn model.entries, eqentry(entry.entryId)
        evolve model,
            entries:  pipe (if idx < 0 then append else adjust(idx))(entry), revtime
            editId:   always(null)
            input:    always(null)

    # :: model -> model
    save = pipe tostate('saving'), dosave, tostate('saved')

    # :: (model, string) -> model
    edit = do ->
        doedit = (model, editId) ->
          input = firstfn model.entries, eqentry(editId)
          mixin model, if input then {editId, input} else {editId:null, input:null}
        pipe doedit, iif get('input'), tostate('valid'), tostate('')

    # :: (date, date) -> model
    load = do ->
        init = (model) -> mixin model,
            state:    null
            input:    null
            editId:   null
        pipe persist.load, init, tostate('')

    {save, setnew, edit, load}
