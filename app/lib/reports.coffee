{tap, pipe, get, apply, converge, I, call, mixin, reverse, map} = require 'fnuc'

{today, toiso} = require './datefun'

module.exports = (persist) ->

    # :: report -> report
    run = do ->
        rev = do ->
            revmonth = (m) -> mixin m, perweek:reverse m.perweek
            pipe map(revmonth), reverse
        alter     = (permonth) -> mixin {permonth}
        runreport = pipe get('fromto'), apply(persist.report)
        doreport  = pipe runreport, get('permonth'), rev, alter
        converge doreport, I, call

    # :: -> report
    init = -> run
        fromto: [
            toiso moment(today()).subtract(1, 'year').toDate()
            toiso moment(today()).add(1, 'year').toDate()
        ],
        permonth: null

    # :: report, s, s -> report
    changedates = (model, from, to) -> mixin model, {fromto:[from, to]}

    # :: report -> report
    refresh = (model) -> run model

    {init, refresh}
