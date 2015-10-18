{nth, iif, sort, evolve, converge, I, always, tap, sort, pipe, get,
mixin, firstfn, eq, indexfn, index, values, split, pick, map} = require 'fnuc'
{append, adjust} = require './immut'
moment = require 'moment'

asUTC = (date) ->
    d = date.toISOString()[0...10]
    new Date "#{d}Z"

revtime = do ->
    gettimeprop = (p) -> (o) -> o[p]?.getTime?()
    timof   = gettimeprop 'time'
    modof   = gettimeprop 'modified'
    sort (o1, o2) -> if (r = timof(o1) - timof(o2)) then r else modof(o1) - modof(o2)

# entries:
#   - userId       String user id
#   - entries      Array of entry
#   - state        model state "saving", "saved"
#   - input        entry of current input
#   - editId       String id of entry being edited

parse = require './parse'

spc = split ' '
hasnullvalue = (o) -> index(values(o), null) >= 0

module.exports = (persist, decorate) ->

    # :: string -> entries -> entries
    tostate = (state) -> evolve {state:always(state)}

    # :: entries -> <persist> -> (saved) entry
    saveinput = pipe get('input'), persist.save

    # :: entries -> boolean
    isvalid = do ->
        props = spc 'date title projectId time'
        check = iif pipe(pick(props), hasnullvalue), always(false), always(true)
        pipe get('input'), check

    # :: string -> entry -> boolean
    eqentry = (entryId) -> pipe(get('entryId'), eq(entryId))

    # :: entries -> entries with update state
    validate  = iif isvalid, tostate('valid'), tostate('invalid')

    # :: (entries, string) -> entries
    setnew = do ->
        doset = (model, entry) -> mixin model, {input:decorate entry}
        converge nth(0), parse, pipe(doset, validate)

    # :: entries -> entries
    dosave = converge I, saveinput, (model, entry) ->
        idx = indexfn model.entries, eqentry(entry.entryId)
        evolve model,
            entries:  pipe (if idx < 0 then append else adjust(idx))(entry), revtime
            editId:   always(null)
            input:    always(null)

    # :: entries -> entries
    save = pipe tostate('saving'), dosave, tostate('saved')

    # :: (entries, string) -> entries
    edit = do ->
        doedit = (model, editId) ->
          input = firstfn model.entries, eqentry(editId)
          mixin model, if input then {editId, input} else {editId:null, input:null}
        pipe doedit, iif get('input'), tostate('valid'), tostate('')

    # :: (date, date) -> entries
    load = do ->
        init = (model) -> mixin model,
            state:    null
            input:    null
            editId:   null
        pipe persist.load, init, tostate('')

    # :: -> entries
    month = ->

        # default time period to load into UI
        start = asUTC moment().subtract(1, 'month').toDate()
        stop  = null

        # load the start model
        load(start, stop)

    {save, setnew, edit, load, month}
