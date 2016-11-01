{connect} = require 'refnux'
{div, span, input, table, tbody} = require('react-elem').DOM
{stopped} = require '../util'
row = require '../log/row'
ismod = require '../../lib/ismod'
later = require '../../lib/later'
saveInput = require '../../actions/save-input'
newInput = require '../../actions/new-input'

module.exports = connect (state, dispatch) -> div class:'input', ->
    {entries} = state
    div class:'main', ->
        input type:'text', placeholder:'t meeting with boss ttn1 3h', onKeyDown: (ev) ->
            el = ev.target
            if ev.keyCode is 13 and entries.state == 'valid'
                if not ismod(ev)
                    dispatch saveInput(entries)
            else
                # later because we need the innerText to contain the last
                # pressed character
                later -> dispatch newInput(entries, el.value)

        div class:'status', ->
            span class:'icon icon-check'
    div class:'below', -> table -> tbody ->
        row 'Today', 'meeting with boss', 'Meetings', 'TT Nyhetsbyrån', '01:00'
