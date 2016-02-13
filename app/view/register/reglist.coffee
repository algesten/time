{each, filter, map} = require 'fnuc'
{view, action} = require 'trifl'
{ol, li, div, pass} = require('trifl').tagg

projectfor  = (clientId) -> filter (p) -> p.clientId == clientId
clientidsof = map (c) -> c.clientId
othersof    = (clientids) -> filter (p) -> not (p.clientId in clientids)

module.exports = view (clients, projects) -> div class:'reglist reportlist', -> ol ->

    each clients.clients, (c) -> li ->
        div class:'section', ->
            div class:'clnt', c.clientId
            div class:'ptitle', c.title
        ol -> each projectfor(c.clientId)(projects.projects), (p) -> li ->
            div class:'proj', p.projectId
            div class:'ctitle', p.title

    others = othersof(clientidsof clients.clients) projects.projects
    if others.length
        div class:'section', ->
            div class:'clnt', ''
            div class:'ptitle others', 'No client'
        ol -> each others, (p) -> li ->
            div class:'proj', p.projectId
            div class:'ctitle', p.title
