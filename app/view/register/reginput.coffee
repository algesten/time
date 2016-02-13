{view, action} = require 'trifl'
{div, input}  = require('trifl').tagg
later = require 'lib/later'
ismod = require 'lib/ismod'

module.exports = reginput = view (model) -> div ->
    input placeholder:'t meeting with boss ttn1 3h', value:'', type:'text', onkeydown: (ev) ->
        el = ev.target
        if ev.keyCode is 13 and model.state == 'valid'
            if not ismod(ev)
                action 'save input', entries
                ev.target.value = ''
        else if ev.keyCode is 27
            console.log '27'
        else
            # later because we need the innerText to contain the last
            # pressed character
            later -> action 'new input', model, el.value
