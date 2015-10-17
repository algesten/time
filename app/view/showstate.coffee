{view} = require 'trifl'
{div}  = require('trifl').tagg

module.exports = view (appstate) -> div ->
    switch appstate.state
        when 'awaiting_startup' then 'Disconnected'
        when 'need_login'       then 'Require login'
        when 'entry'            then 'Ready'
        else 'Unknown'