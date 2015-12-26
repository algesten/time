{always, mixin} = require 'fnuc'

PAGES = ['entries', 'report']

module.exports = do ->

    init = ->
        state: 'disconnected'
        showing: ''

    transition = (model, state) -> mixin model, {state}
    show = (model, showing) ->
        state = if model.state in PAGES then showing else model.state
        mixin model, {showing, state}

    {init, transition, show}
