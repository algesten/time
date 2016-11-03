{div, span, form, input} = require('react-elem').DOM
{each, filter, firstfn} = require 'fnuc'
{stopped}  = require '../util'
{connect}  = require 'refnux'
moment     = require 'moment'
timeamount = require '../../lib/timeamount'

clientfilter = (clientId) -> filter (p) -> p?.projectId?.indexOf(clientId) == 0

module.exports = connect (state, dispatch) -> div key:'report', class:'report', ->
    {clients, projects, report} = state
    permonth = report.permonth ? []
    clientlookup  = require('lib/clientlookup') clients
    projectlookup = require('lib/projectlookup') projects
    div key:'rows', class:'rows', -> each permonth, (month) ->
        div class:'daterow', ->
            div class:'date', moment(month.date).utcOffset(0).format('MMMM')
            div()
            div class:'time sum', timeamount month.seconds
        each month.perclient, (client) ->
            div class:'clientrow', ->
                div class:'id', client.clientId
                div class:'title subsum', clientlookup(client.clientId)?.title ? ''
                div class:'time ctime subsum', timeamount client.seconds
            each clientfilter(client.clientId)(month.projects), (proj) ->
                div class:'clientprojrow', ->
                    div class:'id', proj.projectId
                    div class:'title', projectlookup(proj.projectId)?.title ? ''
                    div class:'time ptime', timeamount proj.seconds

    #         ol -> each clientfilter(client.clientId)(month.projects), (proj) -> li ->
    #             regproj = projectlookup proj.projectId
    #             div class:'proj', ->
    #                 span class:'id', proj.projectId
    #                 pass ' '
    #                 span class:'title', regproj?.title ? ''
    #             div class:'time ptime', timeamount proj.seconds
    #     ol -> each month.perweek, (week) ->  li ->
    #         div class:'week', ->
    #             ws = moment(week.date).format('DD')
    #             we = moment(week.date).add(6, 'days').format('DD')
    #             wk = moment(week.date).format('ww')
    #             "#{ws}–#{we} (#{wk})"
    #         div class:'time wtime', timeamount week.seconds
    #         ol -> each week.projects, (proj) -> li ->
    #             regproj = projectlookup proj.projectId
    #             div class:'proj', ->
    #                 span class:'id', proj.projectId
    #                 pass ' '
    #                 span class:'title', regproj?.title ? ''
    #             div class:'time ptime', timeamount proj.seconds
