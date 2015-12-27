{pipe, iif, I, pfail} = require 'fnuc'
elasticsearch = require 'elasticsearch'
log = require 'bog'

# client to es
client = new elasticsearch.Client
    host: 'localhost:9200'
    log: 'info'
    apiVersion: '2.1'

index = 'totlio'

exists = ->
    ex = client.indices.exists {index}
    ex.then (r) ->
        log.info 'index exists:', r
        r
create = ->
    log.info 'create index'
    client.indices.create {index, type:'entry'}
putmap = (type) -> ->
    log.info 'put mapping', type
    client.indices.putMapping {index, type:type, body:require "./mapping-#{type}"}

# ensure index exists and has the mapping
do pipe (iif exists, I, create), putmap('entry'),
    putmap('client'), putmap('project'), pfail (err) ->
        log.warn 'elastic startup failed', err

module.exports = {client, index}
