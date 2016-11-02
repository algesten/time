{div, span, form, input} = require('react-elem').DOM
{each, map, pipe, get, add, apply, iif, always, partial, I} = require 'fnuc'
{stopped}  = require '../util'
{connect}  = require 'refnux'
moment     = require 'moment'
groupby    = require '../../lib/groupby'
datediff   = require '../../lib/datediff'
timeamount = require '../../lib/timeamount'
beginEdit  = require '../../actions/begin-edit'
later      = require '../../lib/later'
newInput   = require '../../actions/new-input'
stopEdit   = require '../../actions/stop-edit'
saveInput  = require '../../actions/save-input'
deleteEntry = require '../../actions/delete-entry'

grouped = groupby (entry) -> moment(entry.date).format()
sumof = pipe map(get('time')), apply(add(0))

# we want iif(I, _, always('-'))
ifdef = partial iif(always(' ')), I

ifdate = ifdef datediff
ifstr  = ifdef I
iftime = ifdef timeamount

module.exports = connect (state, dispatch) -> div key:'list', class:'list', ->
    {entries} = state

    div key:'input-result', class:'input-result', ->
        # only show result from the input field, not edits
        result = entries?.input unless entries?.editId?
        div key:'input-result-entryrow', class:"entryrow", ->
            div key:"input-result-1st", ->
                span class:'date', ifdate(result?.date)
                span class:'title', ''
            div ifstr(result?._project?.title)
            div ifstr(result?.projectId)
            div iftime(result?.time)

    entrylist = entries?.entries ? []
    gs = grouped entrylist
    projectlookup = require('../../lib/projectlookup') state.projects
    div key:'rows', class:'rows', -> each gs, (g) ->
        div class:'daterow', -> div ->
            span class:'date', datediff(g[0].date)
            span class:'time sum', timeamount sumof g
        each g, (e) ->
            regproj = projectlookup e.projectId
            isedit = e.entryId == entries.editId
            clz = if isedit then 'editing' else ''
            key = e.entryId
            div key:key, class:"entryrow #{clz}", ->
                div key:"#{key}-1st", ->
                    if isedit
                        diddelete = false
                        form ->
                            span class:'icon icon-cancel', onClick: (ev) ->
                                diddelete = true
                                dispatch deleteEntry(entries, e)
                            orig = entries.input?.orig
                            input class:'rowinput', type:'text',
                            key:"#{key}-1st-input", defaultValue:orig
                            , onBlur: (ev) ->
                                # the time between blur and the click event for
                                # icon-cancel is ridiculously long. 50 is not enough,
                                # 100 maybe. and if we let the blur happen with
                                # a redraw, the click event never occurs. we can't win...
                                setTimeout ->
                                    isinput = document.activeElement.classList.contains 'rowinput'
                                    dispatch stopEdit(entries) unless diddelete or isinput
                                , 150
                            , onKeyDown: (ev) ->
                                el = ev.target
                                # later, so we get the key just typed in el.value
                                unless ev.keyCode == 13
                                    later -> dispatch newInput(entries, el.value)
                            if entries.beginEdit
                                # once drawn, put cursor there
                                later -> document.querySelector('.entryrow input')?.focus()
                        , onSubmit: stopped (ev) ->
                            dispatch saveInput(entries)
                    else
                        span class:'title', e.title
                div regproj?.title ? ''
                div e.projectId
                div timeamount e.time
            , onClick: stopped (ev) -> dispatch beginEdit(entries, e.entryId)
