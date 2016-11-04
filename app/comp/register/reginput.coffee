{connect} = require 'refnux'
{div, input, form}  = require('react-elem').DOM
{stopped} = require '../util'
later = require 'lib/later'
ismod = require 'lib/ismod'

newRegInput  = require '../../actions/new-reg-input'
saveRegInput = require '../../actions/save-reg-input'

module.exports = reginput = connect (state, dispatch) -> div key:'reginput', class:'reginput', ->
    {clients, projects} = state
    # we are either adding a client or a project
    isclient = clients?.input?
    model = if isclient then clients else projects
    dosave = -> if model.state == 'valid'
        document.querySelector('#reginputform input').value = ''
        dispatch saveRegInput(isclient, model)
    form id:'reginputform', key:'reginputform', ->
        input placeholder:'ttn/ttn4 name of client or project',
        key:'reginput-input', type:'text', onKeyDown: (ev) ->
            el = ev.target
            unless ev.keyCode == 13
                # later, so we get the key just typed in el.value
                later -> dispatch newRegInput({clients, projects}, el.value)
    , onSubmit: stopped (ev) -> dosave()
