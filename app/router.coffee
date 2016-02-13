{route, path, exec, action} = require 'trifl'

route ->

    toshow = 'entries'

    path '/report', ->
        toshow = 'report'

    path '/register', ->
        toshow = 'register'

    action 'show', toshow
