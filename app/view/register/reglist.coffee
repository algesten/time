{each, filter} = require 'fnuc'
{view, action} = require 'trifl'
{ol, li, div, pass} = require('trifl').tagg

projectfor = (clientId) -> filter (p) -> p.clientId == clientId


module.exports = view (clients, projects) -> div class:'reglist reportlist', -> ol ->
    each clients.clients, (c) -> li ->
        div class:'section', ->
            div class:'clnt', c.clientId
            div class:'ptitle', c.title
        ol -> each projectfor(c.clientId)(projects.projects), (p) -> li ->
            div class:'proj', p.projectId
            div class:'ctitle', p.title
