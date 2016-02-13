{evolve, always, iif, pipe, get, eq, I, call, converge} = require 'fnuc'

module.exports = do ->

    # :: string -> model -> model
    tostate = (state) -> evolve {state:always(state)}

    # :: string -> model -> model|null
    stateis = (state) -> (fn) -> iif pipe(get('state'), eq(state)), fn, always(null)

    # :: ((model) -> string|null) -> (model) -> model
    validate = (isnotvalid) ->
        # :: model -> (model -> state)
        statefn = pipe isnotvalid, (iif I, I, always('valid')), tostate
        converge statefn, I, call

    {tostate, stateis, validate}
