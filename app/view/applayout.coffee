{layout, region} = require 'trifl'
{div}  = require('trifl').tagg

module.exports = layout ->
    div class:'container', ->
        div class:'top', region('top')
        div class:'mid', region('mid')
        div class:'bot', region('bot')
