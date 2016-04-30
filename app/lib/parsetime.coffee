{map, split, index, head, tail, filter, I} = require 'fnuc'

# (3h|3h45|3.45|3:45)

defined = filter I

loc = ->
    amount:   {d:24*60*60, h:60*60, m:60, s:1}
    implicit: ['d', 'h', 'm', 's']

splitnum = split /[^0-9]+/
splitnon = split /[0-9]+/

interpret = (amount, implicit) -> _interpret = (pidx, nums, desg, wasdec=false) ->

    # end here
    return 0 unless nums.length

    dh = head desg           # current designator ('h' or '.' or ':')
    di = index implicit, dh  # index of that designator in the implicit order
    dn = head(nums)          # current number, as a string

    # if the current designator is later in the implicit, we prefer
    # that, otherwise we use the positional index supplied.
    idx = if di > pidx then di else pidx

    # if designator determines, use that, otherwise fall back on
    # implicit for position.
    am = amount[dh] ? amount[implicit[idx]]

    # when there's no designator and the previous designator was a
    # decimal sign, we may pad the next number so that 1.3 is
    # interpreted 1.30
    val = parseInt if di < 0 and wasdec and dn.length == 1 then "#{dn}0" else dn

    # is current designator a decimal sign?
    isdec = dh in ['.', ',']

    # continue recursive interpret
    am * val + _interpret idx + 1, tail(nums), tail(desg), isdec

module.exports = parsetime = (s) ->
    l = loc()
    nums = defined(splitnum s)                # "3h45m" -> ['3', '45']
    return null unless nums.length
    desg = splitnon(s)[1..]                   # "3h45m" -> ['h', 'm', '']
    idx  = if nums.length >= 4 then 0 else 1  # start index in implicit
    interpret(l.amount, l.implicit) idx, nums, desg
