{pipe} = require 'fnuc'
flashinfo = require '../lib/flashinfo'

module.exports = (entries, entry) -> (state, dispatch) ->
    {fn} = state

    todo = pipe (-> fn.entries.delet(entries, entry))
    , ((entries) ->
        dispatch -> {entries})
    , ->
        flashinfo(dispatch, 'Deleted')

    todo()

    {info:'Deleting', running:true}
