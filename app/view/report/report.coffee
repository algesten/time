{layout, region, action} = require 'trifl'
{div}  = require('trifl').tagg
later  = require 'lib/later'

store     = require 'store'

controls   = require './reportcontrols'
reportlist = require './reportlist'

module.exports = report = layout -> div ->
    div region('controls')
    div region('reportlist')

report.controls   controls
report.reportlist reportlist

report.update = ->
    return unless store.viewstate.state == 'report'
    {reports} = store
    if reports
        controls   reports
        reportlist reports
    else
        # lazy report init
        later -> action 'reports init'

report.refresh = ->
    {reports} = store
    if reports
        later -> action 'reports refresh'
