{each, replace} = require 'fnuc'
{view, action} = require 'trifl'
{div, span, pass}  = require('trifl').tagg

NAV = [
    {n:'Entries', v:'entries', i:'icon-clock'}
    {n:'Report', v:'report', i:'icon-paper-plane'}
]

navigate = (state) -> (ev) ->
    ev.stopPropagation()
    ev.preventDefault()
    action 'navigate', state

nosp = replace(/ /g, '_')

module.exports = view (viewstate) -> div class:'nav', ->

    each NAV, (nav) ->
        clz = if nav.v == viewstate.state then 'selected' else null
        div class:clz, onclick: navigate(nav.v), ->
            div class:"icon #{nav.i}"
            pass nav.n

    clist = document.body.classList
    each clist, (cur) -> if cur.indexOf('state-') == 0
        clist.remove cur
    clist.add "state-#{nosp viewstate.state}"