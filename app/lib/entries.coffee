{nth, iif, sort, evolve, converge, I, always, tap, sort, pipe, get, flip,
unapply, apply, mixin, firstfn, eq, indexfn, index, values, split,
pick, map, at, tail, concat, join, fold1, nnot, maybe, call, sub, fold} = require 'fnuc'
{append, adjust, remove} = require './immut'
minimaldate      = require './minimaldate'
moment = require 'moment'

{asutc} = require './datefun'

ifdef = (fn) -> iif I, fn, I

lcomp = (asc) -> (s1, s2) -> s1?.localeCompare(s2)

revtime = do ->
    gettimeprop = (p) -> (o) -> if o[p] then moment(o[p]).unix() else 0
    cexec = (ext, comp) -> (o1, o2) -> comp ext(o1), ext(o2)
    order = [
        cexec gettimeprop('date'), flip(sub)
        cexec get('projectId'), lcomp(true)
        cexec get('title'), lcomp(true)
    ]
    comp = converge order..., unapply(firstfn I)
    sort comp

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

    # :: string -> entries -> entries|null
    stateis = (state) -> (fn) -> iif pipe(get('state'), eq(state)), fn, always(null)

    # the date may have been entered in a relative way 'yy' which must
    # be adjusted to a fixed date in case it's not the same day anymore.
    # :: entry -> entry
    fixorig = do ->
        parseorig = (entry) -> parse {}, entry?.orig
        gettime   = (d) -> moment(d).valueOf()
        samedate  = pipe unapply(I), map(pipe get('date'), gettime), apply(eq)
        dofix    = (entry) ->
            fixed = minimaldate moment(asutc new Date entry.date)
            evolve entry,
                orig:pipe spc, converge always(fixed), tail, pipe(concat, join ' ')
        pipe converge I, parseorig, iif samedate, I, dofix

    # :: (entries, string) -> entries
    edit = do ->
        finder = pipe nth(1), eqentry, firstfn
        entriesof = pipe nth(0), get('entries')
        toinput  = (entry) -> {editId:entry?.entryId, input:entry}
        getinput = converge finder, entriesof, pipe call, ifdef(fixorig), toinput
        converge I, getinput, pipe mixin, iif get('input'), tostate('valid'), tostate('')

    # :: entries, entry -> entries
    update = (model, entry) ->
        idx = indexfn model.entries, eqentry(entry.entryId)
        evolve model,
            entries:  pipe (if idx < 0 then append else adjust(idx))(entry), revtime

    # :: entries, entry -> entries
    erase = (model, entry) ->
        idx = indexfn model.entries, eqentry(entry.entryId)
        evolve model, {entries:remove(idx)}

    # entries -> entries
    unedit = evolve {editId:always(null), input:always(null)}

    # :: entries -> entries
    save = do ->
        saveinput = pipe get('input'), persist.save
        dosave = converge I, saveinput, pipe update, unedit
        stateis('valid') pipe tostate('saving'), dosave, tostate('saved')

    # :: (entries, entry) -> entries
    delet = do ->
        eraseif = iif nth(2), erase, nth(0)
        converge nth(0), nth(1), pipe(nth(1), persist.delete), pipe eraseif, unedit

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
        start = asutc moment().subtract(1, 'month').toDate()
        stop  = null

        # load the start model
        load(start, stop)

    {save, setnew, edit, load, month, delet, update, erase}
