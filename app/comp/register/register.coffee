{div, span, form, input} = require('react-elem').DOM
{each, filter, firstfn, map} = require 'fnuc'
{connect}  = require 'refnux'

projectfor  = (clientId) -> filter (p) -> p.clientId == clientId
clientidsof = map (c) -> c.clientId
othersof    = (clientids) -> filter (p) -> not (p.clientId in clientids)

module.exports = connect (state, dispatch) -> div key:'register', class:'register', ->
    {clients, projects} = state

    # lists
    clist = clients.clients ? []
    plist = projects.projects ? []

    drawsection = (clientId, title, projects) ->
        div key:"reg-#{clientId}", class:'clientrow', ->
            div clientId
            div title
        each projects, (p) -> div key:"reg-p-#{p.projectId}", class:'projectrow', ->
            div p.projectId
            div p.title

    # draw ones that have a grouping client
    each clist, (c) -> drawsection c.clientId, c.title, projectfor(c.clientId)(plist)

    # draw ones that have no client
    others = othersof(clientidsof clist) plist
    if others.length
        drawsection '', 'missing client', others
