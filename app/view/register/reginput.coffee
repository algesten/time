{view, action} = require 'trifl'
{div, input}  = require('trifl').tagg
later = require 'lib/later'
ismod = require 'lib/ismod'

module.exports = reginput = view (clients, projects) -> div ->
    # we are either adding a client or a project
    model = if clients?.input then clients else projects
    both = {clients, projects}
    input placeholder:'ttn/ttn4 name of client or project', type:'text', onkeydown: (ev) ->
        el = ev.target
        if ev.keyCode is 13 and model?.state == 'valid'
            if not ismod(ev)
                action 'save client or project', model
                ev.target.value = ''
        else
            # later because we need the innerText to contain the last
            # pressed character
            later -> action 'new input for clients or projects', both, el.value
