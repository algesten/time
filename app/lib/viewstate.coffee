{always, evolve} = require 'fnuc'

module.exports = (updated) ->

    init = -> state: 'disconnected'
    transition = (model, state) -> evolve model, {state:always(state)}

    {init, transition}
