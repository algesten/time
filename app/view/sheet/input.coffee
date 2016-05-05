{once} = require 'fnuc'
{view, action} = require 'trifl'
{input, div} = require('trifl').tagg
later = require 'lib/later'
ismod = require 'lib/ismod'

module.exports = inputview = view (entries) -> div ->
    val = entries.input
    input placeholder:'t meeting with boss ttn1 3h', type:'text', onkeydown: (ev) ->
        el = ev.target
        if ev.keyCode is 13 and entries.state == 'valid'
            if not ismod(ev)
                ev.target.value = ''
                action 'save input', entries
        else
            # later because we need the innerText to contain the last
            # pressed character
            later -> action 'new input', entries, el.value
    , onfocus: (ev) ->
        action 'new input', entries, ev.target.value
