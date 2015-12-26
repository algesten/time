{layout, region} = require 'trifl'
{div}  = require('trifl').tagg

module.exports = reportcontrols = layout -> div class:'reportcontrols', ->

reportcontrols.update = (reports) ->
