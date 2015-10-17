{layout, region} = require 'trifl'
{div}  = require('trifl').tagg

input     = require './input'

module.exports = sheet = layout ->
    div class:'controls', region('controls')
    div class:'entries', region('entries')

sheet.controls input
