{each, map, pipe, get, add, apply} = require 'fnuc'
{view, action} = require 'trifl'
{ol, li, div} = require('trifl').tagg
groupby    = require 'lib/groupby'
datediff   = require 'lib/datediff'
timeamount = require 'lib/timeamount'

grouped = groupby (entry) -> moment(entry.date).format()
sumof = pipe map(get('time')), apply(add(0))

module.exports = view (entries) -> ol class:'entrylist', ->
    gs = grouped entries?.entries ? []
    each gs, (g) -> li class:'date', datediff(g[0].date), ->
        div class:'totaltime', timeamount sumof g
        ol -> each g, (e) ->
            li class:'entry', ->
                div class:'title',      e.title
                div class:'project-id', e.projectId
                div class:'time',       timeamount e.time
            , onclick: (ev) ->
                ev.stopPropagation()
                ev.preventDefault()
                action 'edit entry', entries, e.entryId
