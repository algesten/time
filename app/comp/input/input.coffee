{connect} = require 'refnux'
{div, span, input, table, tbody} = require('react-elem').DOM
{stopped} = require '../util'
row = require '../log/row'

module.exports = connect (state, dispatch) -> div class:'input', ->
    div class:'main', ->
        input placeholder:'t meeting with boss ttn1 3h'
        div class:'status', ->
            span class:'icon icon-check'
    div class:'below', -> table -> tbody ->
        row 'Today', 'meeting with boss', 'Meetings', 'TT Nyhetsbyrån', '01:00'
