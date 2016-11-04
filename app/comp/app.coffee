{connect} = require 'refnux'
{div, a, span, i} = require('react-elem').DOM
later = require '../lib/later'

module.exports = connect (state, dispatch) -> div key:'container', class:'container', ->
    {info, running, view} = state
    if info
        div id:'info', ->
            if running
                span class:'icon-running'
            span info

    if view == 'login'

        div class:'login', ->
            a href:'/auth/google', 'Login with Google'

    else if view == 'log'

        require('./nav/nav')()
        require('./input/input')()
        require('./log/list')()

    else if view == 'report'

        require('./nav/nav')()
        require('./report/report')()

    else if view == 'register'

        require('./nav/nav')()
        require('./register/reginput')()
        require('./register/register')()
