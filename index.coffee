
port = parseInt process.env.PORT
path = './public'

require('./lib/web.coffee') port, path, ->
