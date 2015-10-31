{iif, always, partial, I} = require 'fnuc'
{view, action} = require 'trifl'
{div}      = require('trifl').tagg
datediff   = require 'lib/datediff'
timeamount = require 'lib/timeamount'

# we want iif(I, _, always('-'))
ifdef = partial iif(always('')), I

ifdate = ifdef datediff
ifstr  = ifdef I
iftime = ifdef timeamount

interpret = view fn = (isedit, entries) -> div ->
    doedit = !isedit == !entries?.editId
    input = if doedit then entries?.input else null
    div class:'main', ->
        div class:'input-holder', ->
        div class:'project-id', ifstr input?.projectId
        div class:'time',  iftime input?.time
        if doedit and entries?.state == 'valid'
            div class:'state icon-check'
    div class:'sub', ->
        div class:'date', ifdate input?.date
        div class:'project-title', ifstr input?._project?.title
        div class:'client-title',  ifstr input?._client?.title

interpret()

# expose inner tagg function
interpret.fn = fn

module.exports = interpret
