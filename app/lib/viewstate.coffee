{always, evolve} = require 'fnuc'

module.exports = do ->

    init = -> state: 'disconnected'
    transition = (model, state) -> evolve model, {state:always(state)}

    {init, transition}
