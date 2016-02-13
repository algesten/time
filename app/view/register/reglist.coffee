{each, filter, map, once} = require 'fnuc'
{view, action} = require 'trifl'
{ol, li, div, pass, input} = require('trifl').tagg
stop  = require 'lib/stop'
later = require 'lib/later'
ismod = require 'lib/ismod'

projectfor  = (clientId) -> filter (p) -> p.clientId == clientId
clientidsof = map (c) -> c.clientId
othersof    = (clientids) -> filter (p) -> not (p.clientId in clientids)

module.exports = view (clients, projects) -> div class:'reglist reportlist', -> ol ->

    unselectonce = once -> action 'edit client', clients, '', projects
    model = if clients.input then clients else projects

    drawinput = (id, title) ->
        input value:title, onfocus: (ev) ->
            ev.target.select()
        , onkeydown: (ev) ->
            el = ev.target
            if ev.keyCode is 13 and model?.state == 'valid'
                if not ismod(ev)
                    action 'save client or project', model
            else if ev.keyCode is 27
                unselectonce()
            else
                # later because we need the innerText to contain the last
                # pressed character
                later ->
                    val = "#{id} #{el.value}"
                    action 'new input for clients or projects', {clients, projects}, val

    drawsection = (clientId, title, arr, clz = '') ->
        div class:"section #{clz}", ->
            iscedit = clientId == clients.editId
            if iscedit
                div class:'delete icon-cancel', onclick: (ev) ->
                    if confirm "Really delete client?"
                        action 'delete client', clients, clients.input
            div class:'clnt', clientId
            div class:'ptitle', ->
                if iscedit
                    drawinput clientId, title
                else
                    pass title
        , onclick: stop (ev) ->
                action 'edit client', clients, clientId, projects
        ol -> each arr, (p) ->
            li ->
                ispedit = p.projectId == projects.editId
                if ispedit
                    div class:'delete icon-cancel', onclick: (ev) ->
                        if confirm "Really delete project?"
                            action 'delete project', projects, projects.input
                div class:'proj', p.projectId
                div class:'ctitle', ->
                    if ispedit
                        drawinput p.projectId, p.title
                    else
                        pass p.title
            , onclick: stop (ev) ->
                action 'edit project', projects, p.projectId, clients

    # draw ones that have a grouping client
    each clients.clients, (c) -> li ->
        drawsection c.clientId, c.title, projectfor(c.clientId)(projects.projects)

    # draw ones that have no client
    others = othersof(clientidsof clients.clients) projects.projects
    if others.length
        li -> drawsection '', 'without client', others, 'others'

    later ->
        el = document.querySelector('.reglist input')
        el?.focus()

    null
