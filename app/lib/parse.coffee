{tap, nth, pipe, converge, split, index, always, values, mixin, I,
iif, evolve, binary, curry, pick} = require 'fnuc'

omap = curry (o, f) -> r = {}; r[k] = f(k,v) for k, v of o; return r

# entry:
#   - entryId    String from persistence
#   - userId     String mandatory
#   - date       Date in UTC mandatory. Rounded to nearest day.
#   - modified   Date. Last time entry was modified.
#   - title      String
#   - time       Number amount of time in seconds
#   - clientId   String
#   - projectId  String
#   - billable   boolean
#   - orig       String original input

# "(t|y|yy|yyyy|day|<date>) Meeting (<project>) (3h?|3h45|3.45)"

spc = split ' '
hasnullvalue = (o) -> index(values(o), null) >= 0
now = -> new Date()
onotnull = omap (k, v) -> if v then v else ''

# :: string -> entry (anemic)
split = (s) ->
    [date, tparts..., projectId, time] = spc s
    title = tparts.join(" ")
    onotnull {date, title, projectId, time}

# :: entry (anemic) -> entry (anemic)
parseparts = evolve
    date: require './parsedate'
    time: require './parsetime'

# :: str -> entry (anemic)
toentry   = pipe split, parseparts

# :: entry (anemic) -> entry
extra = (model, orig, entry) ->
    {userId, projects, editId} = model
    project = projects?[entry.projectId]
    {clientId, billable} = project ? {}
    modified = now()
    mixin entry, {entryId:editId, userId, clientId, billable, orig, modified}

# :: entry -> entry|null
guard = do ->
    props = spc 'date title projectId time'
    iif pipe(pick(props), hasnullvalue), always(null), I

# :: model, str -> entry
parse = converge nth(0), nth(1), pipe(nth(1), toentry), pipe(extra, guard)

module.exports = parse
