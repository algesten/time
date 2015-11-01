{always, mixin} = require 'fnuc'

module.exports = do ->

    init = ->
        state: 'disconnected'

    transition = (model, state) -> mixin model, {state}

    {init, transition}
