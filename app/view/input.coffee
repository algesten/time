{view, action} = require 'trifl'
{input, div} = require('trifl').tagg
later = require 'lib/later'

module.exports = view (entries) -> div class:'input', ->
    val = entries?.input?.orig ? ''
    input type:'text', value:val, onkeydown: (ev) ->
        el = ev.target
        # later because we need the innerText to contain the last
        # pressed character
        later -> action 'newinput', entries, el.value
