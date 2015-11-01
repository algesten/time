{tap, pipe, get, apply, converge, I, call, mixin} = require 'fnuc'

{today, toiso} = require './datefun'

module.exports = (persist) ->

    # :: report -> report
    run = do ->
        alter     = (projects) -> mixin {projects}
        runreport = pipe get('fromto'), apply(persist.report)
        doreport  = pipe runreport, alter
        converge doreport, I, call

    # :: -> report
    init = -> run
        fromto: [
            toiso moment(today()).subtract(1, 'year').toDate()
            toiso today()
        ],
        projects: null

    # :: (report, s, s) -> report
    changedates = (model, from, to) -> mixin model, {fromto:[from, to]}

    {init}
