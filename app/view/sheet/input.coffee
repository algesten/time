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

inputview = view fn = (isedit, entries) -> div ->
    val = entries.input
    unselectonce = once -> action 'edit entry', entries, ''
    doedit = !entries.editId == !isedit
    setval = (if doedit then val?.orig else '') ? ''
    input placeholder:'t meeting with boss ttn1 3h', value:setval, type:'text', onkeydown: (ev) ->
        el = ev.target
        if ev.keyCode is 13 and entries.state == 'valid'
            if not ismod(ev)
                action 'save input', entries
        else if ev.keyCode is 27
            unselectonce()
        else
            # later because we need the innerText to contain the last
            # pressed character
            later -> action 'new input', entries, el.value
    , onfocus: (ev) ->
        ev.target.select()
    # clicks that bubble to doc unselects
    clickdoc unselectonce
, observe: ([mut]) ->
    if mut.type == 'childList'
        [el] = mut.addedNodes
        el.focus() if el.tagName == 'INPUT'


# expose inner tagg function
inputview.fn = fn

module.exports = inputview
