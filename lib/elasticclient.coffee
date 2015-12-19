{pipe, iif, I} = require 'fnuc'
elasticsearch = require 'elasticsearch'

# client to es
client = new elasticsearch.Client
    host: 'localhost:9200'
    log: 'info'
    apiVersion: '2.1'

index = 'totlio'

exists = -> client.indices.exists {index}
create = -> client.indices.create {index, type:'entry'}
putmap = (type) -> ->
    client.indices.putMapping {index, type:type, body:require "./mapping-#{type}"}

# ensure index exists and has the mapping
do pipe (iif exists, I, create), putmap('entry'), putmap('client'), putmap('project')

module.exports = {client, index}
