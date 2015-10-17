{tap, nth, pipe, converge, split, always, mixin, I,
iif, evolve, binary, curry} = require 'fnuc'

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
#   - orig       String original input

# "(t|y|yy|yyyy|day|<date>) Meeting (<project>) (3h?|3h45|3.45)"

spc = split ' '
now = -> new Date()
onotnull = omap (k, v) -> if v then v else ''

# :: string -> entry (anemic)
split = (s) ->
    [date, tparts..., projectId, time] = spc s
    # the above split is greedy for all non-variadic "t meet"
    # will make projectId="meet", but this is not what we want
    if projectId and not tparts.length
        tparts = [projectId]
        projectId = undefined
    if time and not projectId
        projectId = time
        time = undefined
    title = tparts.join(" ")
    onotnull {date, title, projectId, time}

# :: entry (anemic) -> entry (anemic)
parseparts = evolve
    date:      require './parsedate'
    projectId: require './parseproject'
    time:      require './parsetime'

# :: str -> entry (anemic)
toentry   = pipe split, parseparts

# :: entry (anemic) -> entry
extra = (model, orig, entry) ->
    {userId, projects, editId} = model
    project = projects?[entry.projectId]
    {clientId} = project ? {}
    modified = now()
    mixin entry, {entryId:editId, userId, clientId, orig, modified}

# :: model, str -> entry
parse = converge nth(0), nth(1), pipe(nth(1), toentry), extra

module.exports = parse
