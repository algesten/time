{div, span, input} = require('react-elem').DOM
{each, map, pipe, get, add, apply, iif, always, partial, I} = require 'fnuc'
{connect} = require 'refnux'
moment     = require 'moment'
groupby    = require '../../lib/groupby'
datediff   = require '../../lib/datediff'
timeamount = require '../../lib/timeamount'

grouped = groupby (entry) -> moment(entry.date).format()
sumof = pipe map(get('time')), apply(add(0))

row = require './row'

# we want iif(I, _, always('-'))
ifdef = partial iif(always(' ')), I

ifdate = ifdef datediff
ifstr  = ifdef I
iftime = ifdef timeamount

module.exports = connect (state, dispatch) -> div key:'list', class:'list', ->

    div key:'input-result', class:'input-result', ->
        input = state.entries?.input
        row {
            date: ifdate(input?.date)
            title: ''
            projectTitle: ifstr(input?._project?.title)
            projectId: ifstr(input?.projectId)
            time: iftime(input?.time)
        }

    entries = state.entries?.entries ? []
    gs = grouped entries
    projectlookup = require('../../lib/projectlookup') state.projects
    div key:'rows', class:'rows', -> each gs, (g) ->
        div class:'daterow', -> div ->
            span class:'date', datediff(g[0].date)
            span class:'time sum', timeamount sumof g
        each g, (e) ->
            regproj = projectlookup e.projectId
            row {
                title:e.title
                projectTitle:regproj?.title ? ''
                projectId:e.projectId
                time: timeamount e.time
                key: e.entryId
            }
        # div class:'date', datediff(g[0].date)
        # div class:'totaltime', timeamount sumof g
        # ol -> each g, (e) ->
        #     if entries.editId == e.entryId
        #         li ->
        #             div class:'controls-inline', ->
        #                 # editing entry
        #                 div class:'delete icon-cancel', onclick: (ev) ->
        #                     if confirm "Really delete entry?"
        #                         action 'delete entry', entries, e
        #                 div class:'interpret', -> interpret.fn(true, entries)
        #                 div class:'input',     -> edit(entries)
        #             , onclick: stop (ev) -> false # no clickyclick
        #     else
        #         li class:'entry', ->
        #             div class:'title',      e.title
        #             regproj = projectlookup e.projectId
        #             if regproj
        #                 div class:'project-title', regproj.title
        #             div class:'project-id', e.projectId
        #             div class:'time',       timeamount e.time
        #         , onclick: stop (ev) ->
        #             action 'edit entry', entries, e.entryId
