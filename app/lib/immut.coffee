{concat, set, shallow, curry} = require 'fnuc'

append = curry (as, a) -> concat as, [a]
adjust = curry (as, a, idx) -> concat as[0...idx], [a], as[idx+1...as.length]
remove = curry (as, idx) ->
    if idx >= 0
        concat as[0...idx], as[idx+1...as.length]
    else
        as
attach = curry (o, k, v) -> set shallow(o), k, v

module.exports = {append, adjust, attach, remove}
