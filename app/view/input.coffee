{view, action} = require 'trifl'
{div} = require('trifl').tagg
later = require 'lib/later'

module.exports = view (entries) ->
    div contenteditable:true, onkeydown: (ev) ->
        el = ev.target
        later -> action 'newentry', entries, el.innerText
