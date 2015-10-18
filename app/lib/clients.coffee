{converge} = require 'fnuc'

module.exports = (persist) ->

    init = do ->
        doinit = (clients, projects) ->
            {clients, projects}
        fn = converge persist.clients, persist.projects, doinit
        -> fn() # no arguments

    {init}
