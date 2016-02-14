{each} = require 'fnuc'

module.exports = (clients) ->
    lookup = {}
    each (clients?.clients ? []), (c) -> lookup[c.clientId] = c
    (id) -> lookup[id]
