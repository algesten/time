{map, split, index, head, tail, filter, I} = require 'fnuc'

# (3h|3h45|3.45|3:45)

defined = filter I

loc = ->
    amount:   {d:24*60*60, h:60*60, m:60, s:1}
    implicit: ['d', 'h', 'm', 's']

splitnum = split /[^0-9]+/
splitnon = split /[0-9]+/

interpret = (amount, implicit) -> _interpret = (pidx, nums, desg) ->
    # end here
    return 0 unless nums.length
    dh = head desg           # current designator ('h' or '.' or ':')
    di = index implicit, dh  # index of that designator in the implicit order
    # if the current designator is later in the implicit, we prefer
    # that, otherwise we use the positional index supplied.
    idx = if di > pidx then di else pidx
    # if designator determines, use that, otherwise fall back on
    # implicit for position.
    am = amount[dh] ? amount[implicit[idx]]
    # continue recursive interpret
    am * head(nums) + _interpret idx + 1, tail(nums), tail(desg)

module.exports = parsetime = (s) ->
    l = loc()
    nums = map defined(splitnum s), parseInt  # "3h45m" -> [3, 45]
    return null unless nums.length
    desg = splitnon(s)[1..]                   # "3h45m" -> ['h', 'm', '']
    idx  = if nums.length >= 4 then 0 else 1  # start index in implicit
    interpret(l.amount, l.implicit) idx, nums, desg
