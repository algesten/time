{once} = require 'fnuc'
{view, action} = require 'trifl'
{input, div} = require('trifl').tagg
later = require 'lib/later'
ismod = (ev) -> ev.ctrlKey || ev.metaKey || ev.shiftKey || ev.altKey

inputview = view fn = (entries) -> div ->
    val = entries.input
    unselectonce = once ->
        action 'edit entry', entries, '' # unselect
    input placeholder:'t meeting tst1 2', value:val?.orig, type:'text', onkeydown: (ev) ->
        el = ev.target
        if ev.keyCode is 13
            if not ismod(ev)
                action 'save input', entries
                unselectonce()
        else
            # later because we need the innerText to contain the last
            # pressed character
            later -> action 'new input', entries, el.value
    , onfocus: (ev) ->
        ev.target.select()
    , onblur:  (ev) ->
        action 'edit entry', entries, '' # unselect
, observe: ([mut]) ->
    if mut.type == 'childList'
        [el] = mut.addedNodes
        el.focus() if el.tagName == 'INPUT'


# expose inner tagg function
inputview.fn = fn

module.exports = inputview
