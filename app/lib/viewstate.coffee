{always, evolve} = require 'fnuc'

module.exports = (updated) ->

    init = -> state: 'awaiting_startup'
    transition = (model, state) -> evolve model, {state:always(state)}

    {init, transition}

# awaiting_startup
# need_login
# entry
