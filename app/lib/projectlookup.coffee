{each} = require 'fnuc'

module.exports = (projects) ->
    lookup = {}
    each (projects?.projects ? []), (p) -> lookup[p.projectId] = p
    (id) -> lookup[id]
