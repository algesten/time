{connect} = require 'refnux'
{div, span, input, table, tbody, form, button} = require('react-elem').DOM
{stopped} = require '../util'
ismod = require '../../lib/ismod'
later = require '../../lib/later'
saveInput = require '../../actions/save-input'
newInput = require '../../actions/new-input'
{stopped} = require '../util'

module.exports = connect (state, dispatch) -> div key:'input', class:'input', ->
    {entries} = state
    dosave = -> if entries.state == 'valid'
        dispatch saveInput(entries)
    form id:'inputform', key:'inputform', ->
        div key:'input-main', class:'main', ->
            input key:'input', type:'text', defaultValue:'',
            placeholder:'t meeting with boss ttn1 3h', onKeyDown: (ev) ->
                el = ev.target
                # later, so we get the key just typed in el.value
                unless ev.keyCode == 13
                    later -> dispatch newInput(entries, el.value)
            div class:'status', ->
                if entries.state == 'valid' and not entries.editId?
                    span class:'icon icon-check', onClick: stopped (ev) -> dosave()
    , onSubmit: stopped (ev) -> dosave()
