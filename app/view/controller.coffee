{handle} = require 'trifl'
store    = require 'store'

applayout = require './applayout'
nav       = require './nav'
sheet     = require './sheet'
report    = require './report'
register  = require './register'
login     = require './login'

handle 'update:viewstate', ->
    applayout.top nav

    applayout.mid switch store.viewstate.state
        when 'entries'       then sheet
        when 'report'        then report
        when 'register'      then register
        when 'require login' then login
        else null

    update()

handle 'update:entries', ->
    update()
    report.refresh()

handle 'update:reports', ->
    update()

update = ->
    nav store.viewstate
    sheet.update()
    report.update()
    register.update()