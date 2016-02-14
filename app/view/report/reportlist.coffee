{each, filter, firstfn} = require 'fnuc'
{view, action} = require 'trifl'
{ol, li, div, pass, span} = require('trifl').tagg
timeamount = require 'lib/timeamount'

clientfilter = (clientId) -> filter (p) -> p?.projectId?.indexOf(clientId) == 0

module.exports = view (reports, clients, projects) -> div class:'reportlist', -> ol ->
    {permonth} = reports
    clientlookup  = require('lib/clientlookup') clients
    projectlookup = require('lib/projectlookup') projects
    each permonth, (month) -> li ->
        div class:'section', ->
            div class:'month', moment(month.date).format('MMMM')
            div class:'time mtime',  timeamount month.seconds
        ol -> each month.perclient, (client) -> li ->
            regcli = clientlookup client.clientId
            div class:'clnt', ->
                span class:'id', client.clientId
                pass ' '
                span class:'title', regcli?.title ? ''
            div class:'time ctime', timeamount client.seconds
            ol -> each clientfilter(client.clientId)(month.projects), (proj) -> li ->
                regproj = projectlookup proj.projectId
                div class:'proj', ->
                    span class:'id', proj.projectId
                    pass ' '
                    span class:'title', regproj?.title ? ''
                div class:'time ptime', timeamount proj.seconds
        ol -> each month.perweek, (week) ->  li ->
            div class:'week', ->
                ws = moment(week.date).format('DD')
                we = moment(week.date).add(6, 'days').format('DD')
                wk = moment(week.date).format('ww')
                "#{ws}–#{we} (#{wk})"
            div class:'time wtime', timeamount week.seconds
            ol -> each week.projects, (proj) -> li ->
                regproj = projectlookup proj.projectId
                div class:'proj', ->
                    span class:'id', proj.projectId
                    pass ' '
                    span class:'title', regproj?.title ? ''
                div class:'time ptime', timeamount proj.seconds
