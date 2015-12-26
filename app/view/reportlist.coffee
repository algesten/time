{each} = require 'fnuc'
{view, action} = require 'trifl'
{ol, li, div, pass} = require('trifl').tagg
timeamount = require 'lib/timeamount'

module.exports = view (reports) -> div class:'reportlist', -> ol ->
    {permonth} = reports
    each permonth, (month) -> li ->
        div class:'mwrap', ->
            div class:'month', moment(month.date).format('MMMM')
            div class:'time mtime',  timeamount month.seconds
        ol -> each month.perweek, (week) ->  li ->
            div class:'week', ->
                ws = moment(week.date).format('DD')
                we = moment(week.date).add(6, 'days').format('DD')
                wk = moment(week.date).format('ww')
                "#{ws}–#{we} (#{wk})"
            div class:'time wtime', timeamount week.seconds
            ol -> each week.projects, (proj) -> li ->
                div class:'proj', proj.projectId
                div class:'time ptime', timeamount proj.seconds
