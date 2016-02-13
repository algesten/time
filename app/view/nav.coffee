{each, replace} = require 'fnuc'
{view, action} = require 'trifl'
{div, span, pass, a}  = require('trifl').tagg

NAV = [
    {n:'Entries',  v:'entries',  i:'icon-clock',       p:'/'}
    {n:'Report',   v:'report',   i:'icon-paper-plane', p:'/report'}
    {n:'Register', v:'register', i:'icon-vcard',       p:'/register'}
]

navigate = (path) -> (ev) ->
    ev.stopPropagation()
    ev.preventDefault()
    action 'navigate', path

nosp = replace(/ /g, '_')

module.exports = view (viewstate) -> div class:'nav', ->

    each NAV, (nav) ->
        clz = if nav.v == viewstate.state then 'selected' else null
        a class:clz, href:"#{nav.p}", onclick: navigate(nav.p), ->
            div class:"icon #{nav.i}"
            pass nav.n

    clist = document.body.classList
    each clist, (cur) -> if cur.indexOf('state-') == 0
        clist.remove cur
    clist.add "state-#{nosp viewstate.state}"