{connect} = require 'refnux'
{div, a, span, i} = require('react-elem').DOM

module.exports = connect (state, dispatch) -> div ->
    {info, running} = state
    if info
        div id:'info', ->
            if running
                span class:'icon-running'
            span info
