{view, action} = require 'trifl'
{input, div} = require('trifl').tagg
later = require 'lib/later'

ismod = (ev) -> ev.ctrlKey || ev.metaKey || ev.shiftKey || ev.altKey

module.exports = view (entries) -> div class:'input', ->
    val = entries.input
    input class:'input', value:val?.orig, type:'text', onkeydown: (ev) ->
        el = ev.target
        if ev.keyCode is 13
            if not ismod(ev)
                action 'save input', entries
        else
            # later because we need the innerText to contain the last
            # pressed character
            later -> action 'new input', entries, el.value
