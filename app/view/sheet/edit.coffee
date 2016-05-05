{once} = require 'fnuc'
{view, action} = require 'trifl'
{input, div} = require('trifl').tagg
later = require 'lib/later'
ismod = require 'lib/ismod'

clickdoc = do ->
    cur = null # current handler so we don't leak
    (fn) ->
        document.removeEventListener 'click', cur if cur
        document.addEventListener 'click', cur = fn

module.exports = do ->
    # the previous edit id to sense whether we are to set
    # a new one.
    prevEditId = null
    (entries) -> div ->
        console.log entries
        val = entries.input
        unselectonce = once ->
            prevEditId = null
            action 'edit entry', entries, ''
        doedit = entries.editId and (prevEditId != entries.editId)
        setval = if doedit then {value:val?.orig ? ''} else null
        prevEditId = entries.editId
        input setval, type:'text', onkeydown: (ev) ->
            el = ev.target
            if ev.keyCode is 13 and entries.state == 'valid'
                if not ismod(ev)
                    prevEditId = null
                    ev.target.value = ''
                    action 'save input', entries
            else if ev.keyCode is 27
                unselectonce()
            else
                # later because we need the innerText to contain the last
                # pressed character
                later -> action 'new input', entries, el.value
        # clicks that bubble to doc unselects
        clickdoc unselectonce
    , observe: ([mut]) ->
        # on first attached to DOM, focus
        if mut.type == 'childList'
            [el] = mut.addedNodes
            el.focus() if el?.tagName == 'INPUT'
