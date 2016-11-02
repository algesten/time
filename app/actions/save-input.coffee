{pipe} = require 'fnuc'
flashinfo = require '../lib/flashinfo'

module.exports = (entries) -> (state, dispatch) ->
    {fn} = state

    todo = pipe (-> fn.entries.save(entries))
    , ((entries) ->
        dispatch -> {entries})
    , ->
        flashinfo(dispatch, 'Saved')

    todo()

    {info:'Saving', running:true}
