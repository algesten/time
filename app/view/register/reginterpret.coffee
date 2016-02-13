{iif, always, partial, I} = require 'fnuc'
{view, action} = require 'trifl'
{div, pass} = require('trifl').tagg

# we want iif(I, _, always('-'))
ifdef = partial iif(always('')), I

ifstr  = ifdef I

interpret = view fn = (clients, projects) -> div ->
    # we are either looking at clients or projets
    model = if clients?.input then clients else projects
    isproject = !!model?.input?.projectId
    isclient =  !isproject and !!model?.input?.clientId
    div class:'main', ->
        div class:'input-holder', -> # filler to reuse styling
        if isproject
            div class:'project-id', model.input.projectId
        else
            div class:'client-id', model?.input?.clientId
        if model?.state == 'valid'
            div class:'state icon-check'
    div class:'sub', ->
        type = if isproject then 'project' else if isclient then 'client' else null
        err = switch model?.state ? ''
            when 'nullval' then ' (incomplete)'
            when 'exists'  then ' (already exists)'
            else ''
        if type
            div class:'result', "Adding #{type} #{err}"

interpret()

# expose inner tagg function
interpret.fn = fn

module.exports = interpret
