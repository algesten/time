{layout, region} = require 'trifl'
{div}  = require('trifl').tagg

reginterpret = require './reginterpret'
reginput     = require './reginput'

module.exports = regcontrols = layout -> div class:'regcontrols', ->
    div class:'interpret', region('interpret')
    div class:'input',     region('input')

regcontrols.interpret reginterpret
regcontrols.input reginput

regcontrols.update = (clients, projects) ->
    reginterpret clients, projects
    reginput     clients, projects
