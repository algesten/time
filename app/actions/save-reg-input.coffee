{pipe} = require 'fnuc'
flashinfo = require '../lib/flashinfo'

module.exports = (isclient, model) -> (state, dispatch) ->
    {fn} = state

    todo = if isclient
        pipe (-> fn.clients.save(model))
        , ((clients) -> dispatch -> {clients})
        , -> flashinfo(dispatch, 'Saved')
    else
        pipe (-> fn.projects.save(model))
        , ((projects) -> dispatch -> {projects})
        , -> flashinfo(dispatch, 'Saved')

    todo()

    {info:'Saving', running:true}
