{converge, pipe} = require 'fnuc'
flashinfo = require '../lib/flashinfo'

module.exports = (state, dispatch) ->
    {fn} = state

    loadentries  = pipe fn.entries.month, (entries)  -> dispatch -> {entries}
    loadclients  = pipe fn.clients.init,  (clients)  -> dispatch -> {clients}
    loadprojects = pipe fn.projects.init, (projects) -> dispatch -> {projects}
    loadstuff = converge loadentries, loadclients, loadprojects, -> flashinfo dispatch, 'Started'

    loadstuff()

    {info:"Loading…", running:true}
