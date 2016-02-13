{layout, region, action} = require 'trifl'
{div}  = require('trifl').tagg
later  = require 'lib/later'

store  = require 'store'

controls = require './regcontrols'
reglist  = require './reglist'

module.exports = register = layout -> div ->
    div region('controls')
    div region('reglist')

register.controls controls
register.reglist  reglist

register.update = ->
    return unless store.viewstate.state == 'register'
    {clients, projects} = store
    if clients and projects
        controls.update clients, projects
        reglist clients, projects
