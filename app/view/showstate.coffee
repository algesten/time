{view} = require 'trifl'
{div}  = require('trifl').tagg

module.exports = view (appstate) -> div ->
    switch appstate.state
        when 'awaiting_startup' then 'disconnected'
        when 'need_login'       then 'require login'
        when 'loading'          then 'loading'
        when 'entry'            then 'ready'
        else appstate.state
