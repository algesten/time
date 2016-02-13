{layout, region} = require 'trifl'
{div}  = require('trifl').tagg

reginput = require './reginput'

module.exports = regcontrols = layout -> div class:'regcontrols', ->
    div class:'interpret', region('interpret')
    div class:'input',     region('input')

regcontrols.input reginput

regcontrols.update = (clients, projects) ->
    reginput clients, projects
