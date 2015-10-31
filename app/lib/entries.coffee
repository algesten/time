{nth, iif, sort, evolve, converge, I, always, tap, sort, pipe, get,
unapply, apply, mixin, firstfn, eq, indexfn, index, values, split,
pick, map, at, tail, concat, join, fold1, nnot, maybe, call} = require 'fnuc'
{append, adjust} = require './immut'
minimaldate      = require './minimaldate'
moment = require 'moment'

asUTC = (date) ->
    d = date.toISOString()[0...10]
    new Date "#{d}T00:00:00Z"

revtime = do ->
    gettimeprop = (p) -> (o) -> if o[p] then moment(o[p]).unix() else 0
    dateof   = gettimeprop 'date'
    modof    = gettimeprop 'modified'
    sort (o2, o1) -> if (r = dateof(o1) - dateof(o2)) then r else modof(o1) - modof(o2)

# entries:
#   - userId       String user id
#   - entries      Array of entry
#   - state        model state "saving", "saved"
#   - input        entry of current input
#   - editId       String id of entry being edited

parse = require './parse'

spc = split ' '
hasnullvalue = pipe values, fold1((a,b) -> !!a and !!b), nnot

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

    # :: string -> entries -> entries|null
    stateis = (state) -> (fn) -> iif pipe(get('state'), eq(state)), fn, always(null)

    # :: entries -> entries
    save = stateis('valid') pipe tostate('saving'), dosave, tostate('saved')

    # the date may have been entered in a relative way 'yy' which must
    # be adjusted to a fixed date in case it's not the same day anymore.
    # :: entry -> entry
    fixorig = do ->
        parseorig = (entry) -> parse {}, entry?.orig
        gettime   = (d) -> moment(d).valueOf()
        samedate  = pipe unapply(I), map(pipe get('date'), gettime), apply(eq)
        dofix    = (entry) ->
            fixed = minimaldate(moment()) moment(entry.date)
            evolve entry,
                orig:pipe spc, converge always(fixed), tail, pipe(concat, join ' ')
        pipe converge I, parseorig, iif samedate, I, dofix

    # :: (entries, string) -> entries
    edit = do ->
        finder = pipe nth(1), eqentry, firstfn
        entriesof = pipe nth(0), get('entries')
        toinput  = (entry) -> {editId:entry?.entryId, input:entry}
        getinput = converge finder, entriesof, pipe call, toinput
        converge I, getinput, pipe mixin, iif get('input'), tostate('valid'), tostate('')

    # :: (entries, string) -> entries
    delet = do ->
        finder = pipe nth(1), eqentry, firstfn
        entriesof   = pipe nth(0), get('entries')
        converge finder, entriesof, pipe call, maybe(persist.delete)

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

    {save, setnew, edit, load, month, delet}
