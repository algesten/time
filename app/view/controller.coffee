{handle} = require 'trifl'
store    = require 'store'

applayout = require './applayout'
nav       = require './nav'
sheet     = require './sheet'
login     = require './login'

handle 'update:viewstate', ->
    applayout.top nav

    applayout.mid switch store.viewstate.state
        when 'entries'       then sheet
        when 'require login' then login
        else null

    update()

handle 'update:entries', ->
    update()

update = ->
    nav store.viewstate
    sheet.update()
