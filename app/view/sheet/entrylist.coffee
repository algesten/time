{each, map, pipe, get, add, apply} = require 'fnuc'
{view, action} = require 'trifl'
{ol, li, div} = require('trifl').tagg
stop       = require 'lib/stop'
groupby    = require 'lib/groupby'
datediff   = require 'lib/datediff'
timeamount = require 'lib/timeamount'

interpret = require './interpret'
edit      = require('./edit')

grouped = groupby (entry) -> moment(entry.date).format()
sumof = pipe map(get('time')), apply(add(0))

module.exports = view (entries, projects) -> ol class:'entrylist', ->
    gs = grouped entries?.entries ? []
    projectlookup = require('lib/projectlookup') projects
    each gs, (g) -> li ->
        div class:'date', datediff(g[0].date)
        div class:'totaltime', timeamount sumof g
        ol -> each g, (e) ->
            if entries.editId == e.entryId
                li ->
                    div class:'controls-inline', ->
                        # editing entry
                        div class:'delete icon-cancel', onclick: (ev) ->
                            if confirm "Really delete entry?"
                                action 'delete entry', entries, e
                        div class:'interpret', -> interpret.fn(true, entries)
                        div class:'input',     -> edit(entries)
                    , onclick: stop (ev) -> false # no clickyclick
            else
                li class:'entry', ->
                    div class:'title',      e.title
                    regproj = projectlookup e.projectId
                    if regproj
                        div class:'project-title', regproj.title
                    div class:'project-id', e.projectId
                    div class:'time',       timeamount e.time
                , onclick: stop (ev) ->
                    action 'edit entry', entries, e.entryId
