{layout, region} = require 'trifl'
{div}  = require('trifl').tagg

interpret = require './interpret'
input     = require './input'

module.exports = controls = layout -> div class:'controls', ->
    div class:'interpret', region('interpret')
    div class:'input', region('input')

controls.interpret interpret
controls.input     input

controls.update = (entries) ->
    interpret entries
    input     entries
