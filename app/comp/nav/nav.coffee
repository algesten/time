{connect} = require 'refnux'
{div, a, span} = require('react-elem').DOM
{stopped} = require '../util'
{navigate} = require 'broute'


module.exports = connect (state, dispatch) -> div class:'nav', ->
    {views, view} = state
    views.forEach (v) ->
        cl = if v.id == view then 'selected' else ''
        a class:cl, href:v.href, ->
            span class:"icon icon-#{v.icon}"
            span v.id
        , onClick: stopped (ev) -> navigate v.href
