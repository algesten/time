{view, action} = require 'trifl'
{div} = require('trifl').tagg
later = require 'lib/later'

module.exports = view (model) ->
    div contenteditable:true, onkeydown: (ev) ->
        el = ev.target
        later -> action 'newentry', model, el.innerText
