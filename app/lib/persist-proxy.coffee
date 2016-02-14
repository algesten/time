{omap} = require 'fnuc'

plug = (rs, rj) -> (err, res) -> if err then rj(err) else rs(res)

module.exports = (emit) ->
    funs = require './persist'
    omap funs, (name, fn) -> (as...) -> new Promise (rs, rj) -> emit name, as, plug(rs, rj)
