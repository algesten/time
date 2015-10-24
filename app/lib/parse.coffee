{tap, nth, pipe, converge, split, always, mixin, I,
iif, evolve, binary, curry, get, slice, maybe, omap} = require 'fnuc'

parsedate    = require './parsedate'
parseproject = require './parseproject'
parsetime    = require './parsetime'

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
    parts = spc s
    [date, tparts..., projectId, time] = parts
    if parseproject(time)
        # no time (yet)
        time = null; [date, tparts..., projectId] = parts
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
    date:      parsedate
    projectId: parseproject
    time:      parsetime

# :: entry -> entry
addclient = do ->
    add = (model, clientId) -> mixin model, {clientId}
    converge I, pipe(get('projectId'), maybe(slice 0,3)), add

# :: str -> entry (anemic)
toentry = pipe split, parseparts, addclient

# :: entry (anemic) -> entry
extra = (entries, orig, entry) ->
    {userId, editId} = entries
    modified = now()
    mixin entry, {entryId:editId, userId, orig, modified}

# :: entries, str -> entry
parse = converge nth(0), nth(1), pipe(nth(1), toentry), extra

module.exports = parse
