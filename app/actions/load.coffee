{converge, pipe} = require 'fnuc'
flashinfo = require '../lib/flashinfo'

module.exports = (state, dispatch) ->
    {fn} = state

    loadentries  = pipe fn.entries.month, (entries)  -> dispatch -> {entries}
    loadclients  = pipe fn.clients.init,  (clients)  -> dispatch -> {clients}
    loadprojects = pipe fn.projects.init, (projects) -> dispatch -> {projects}
    loadstuff = converge loadentries, loadclients, loadprojects

    todo = pipe loadstuff
    , (-> flashinfo dispatch, 'Started')

    todo()

    {info:"Loading…", running:true}
