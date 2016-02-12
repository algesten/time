{pipe, fold1, nnot, values} = require 'fnuc'

module.exports = hasnullvalue = pipe values, fold1((a,b) -> !!a and !!b), nnot
