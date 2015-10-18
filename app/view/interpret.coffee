{iif, always, partial, I} = require 'fnuc'
{view, action} = require 'trifl'
{div}      = require('trifl').tagg
datediff   = require 'lib/datediff'
timeamount = require 'lib/timeamount'

# we want iif(I, _, always('-'))
ifdef = partial iif(always('-')), I

ifdate = ifdef datediff
ifstr  = ifdef I
iftime = ifdef timeamount

module.exports = interpret = view (entries) -> div class:'interpret', ->
    input = entries?.input
    div class:'date', ifdate input?.date
    div class:'title', ifstr input?.title
    div class:'project', ->
        div class:'project-id',    ifstr input?.projectId
        div class:'project-title', ifstr input?._project?.title
        div class:'client-title',  ifstr input?._client?.title
    div class:'time',  iftime input?.time
    div class:'state', ifstr entries?.state

interpret()
