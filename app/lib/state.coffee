{evolve, always, iif, pipe, get, eq} = require 'fnuc'

module.exports = do ->

    # :: string -> model -> model
    tostate = (state) -> evolve {state:always(state)}

    # :: string -> model -> model|null
    stateis = (state) -> (fn) -> iif pipe(get('state'), eq(state)), fn, always(null)

    # :: ((model) -> boolean) -> (model) -> model
    validate = (isvalid) -> iif isvalid, tostate('valid'), tostate('invalid')

    {tostate, stateis, validate}
