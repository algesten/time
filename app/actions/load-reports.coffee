{pipe, I} = require 'fnuc'
flashinfo = require '../lib/flashinfo'
later = require '../lib/later'

module.exports = (refresh) -> (state, dispatch) ->
    {fn, report} = state

    handle = pipe ((report) -> dispatch -> {report}), -> flashinfo(dispatch, 'Report loaded')

    todo = if report.fromto
        if refresh then pipe(fn.reports.refresh, handle) else I
    else
        pipe fn.reports.init, handle

    later -> todo(report)

    {info:'Loading report', running:true}
