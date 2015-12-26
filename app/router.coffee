{route, path, exec, action} = require 'trifl'

route ->

    toshow = 'entries'

    path '/report', ->
        toshow = 'report'

    action 'show', toshow
