{concat, set, shallow, curry} = require 'fnuc'

append = curry (as, a) -> concat as, [a]
adjust = curry (as, a, idx) -> concat as[0...idx], [a], as[idx+1...as.length]
attach = curry (o, k, v) -> set shallow(o), k, v

module.exports = {append, adjust, attach}
