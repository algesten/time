{connect} = require 'refnux'
{div, a, span, i} = require('react-elem').DOM

module.exports = connect (state, dispatch) -> div class:'container', ->
    {info, running, view} = state
    if info
        div id:'info', ->
            if running
                span class:'icon-running'
            span info
    if view == 'login'
        div class:'login', ->
            a href:'/auth/google', 'Login with Google'
    else
        require('./nav/nav')()
        require('./input/input')()
