{pipe} = require 'fnuc'

# test if the given string is a project
isproject = pipe require('../lib/parseproject').grok, (v) -> !!v

module.exports = ({clients, projects}, value) -> (state) ->
    {fn} = state
    if isproject(value)
        {
            projects: fn.projects.setnew(projects, value)
            clients:  fn.clients.edit(clients, '')
        }
    else
        {
            clients: fn.clients.setnew(clients, value)
            projects:  fn.projects.edit(projects, '')
        }
