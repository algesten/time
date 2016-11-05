{pipe, iif, I, pfail, unary} = require 'fnuc'
elasticsearch = require 'elasticsearch'
log = require 'bog'

# switch when we start logging elastic stuff
startlog = false

wraplog = (fn) -> (as...) -> fn(as...) if startlog

class ElasticLogger
    error:   wraplog log.error
    warning: wraplog log.warn
    info:    wraplog log.info
    debug:   wraplog log.debug
    trace: (method, url, body, response, status) ->

# client to es
client = new elasticsearch.Client
    host: 'elasticsearch:9200'
    log: ElasticLogger
    apiVersion: '5.0'

index = 'totlio'

wait = -> new Promise (rs) -> setTimeout (->rs()), 1000

waitforup = ->
    log.info 'waiting for elastic'
    dowait = -> wait().then ->
        client.ping()
    .then ->
        log.info 'elastic is up'
        startlog = true
    .catch (err) ->
        # not up, try again
        dowait()
    dowait()

putmap = (type) -> (a) ->
    log.info 'put mapping', type
    client.indices.putMapping {
        index, type, update_all_types:true, body:require("./mapping-#{type}")
    }

maybecreate = -> client.indices.exists({index}).then (ex) ->
    log.info 'index exists', ex
    unless ex
        log.info 'create index'
        client.indices.create {index}

# ensure index exists and has the mapping
do pipe waitforup, maybecreate, putmap('entry'), putmap('client'), putmap('project'), pfail (err) ->
    log.warn 'elastic startup failed', err

module.exports = {client, index}
