{connect} = require 'refnux'
{div, a, span, i} = require('react-elem').DOM

module.exports = connect (state, dispatch) -> div class:'container', ->
    {info, running} = state
    if info
        div id:'info', ->
            if running
                span class:'icon-running'
            span info
    require('./nav/nav')()
    require('./input/input')()
