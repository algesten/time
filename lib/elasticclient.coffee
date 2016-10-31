{pipe, iif, I, pfail, unary} = require 'fnuc'
elasticsearch = require 'elasticsearch'
log = require 'bog'

# client to es
client = new elasticsearch.Client
    host: 'localhost:9200'
    log: 'info'
    apiVersion: '5.0'

index = 'totlio'

putmap = (type) -> (a) ->
    log.info 'put mapping', type
    client.indices.putMapping {index, type, body:require "./mapping-#{type}"}

maybecreate = -> client.indices.exists({index}).then (ex) ->
    log.info 'index exists', ex
    unless ex
        log.info 'create index'
        client.indices.create {index}

# ensure index exists and has the mapping
do pipe maybecreate, putmap('entry'), putmap('client'), putmap('project'), pfail (err) ->
    log.warn 'elastic startup failed', err

module.exports = {client, index}
