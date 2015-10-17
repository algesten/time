{pipe, iif, I} = require 'fnuc'
elasticsearch = require 'elasticsearch'

# client to es
client = new elasticsearch.Client
    host: 'localhost:9200'
    log: 'trace'
    apiVersion: '1.7'

index = 'totlio'

exists = -> client.indices.exists {index}
create = -> client.indices.create {index, type:'entry'}
putmap = -> client.indices.putMapping {index, type:'entry', body:require('./mapping-entry')}

# ensure index exists and has the mapping
do pipe (iif exists, I, create), putmap

# persistence to database
module.exports =

    load: (user, start, stop) ->
        client.search {index, type:'entry', body:query:filtered:
            filter:term:userId:user.id
            query:range:date:{gte:start,lt:stop}}
        .then (res) ->
            {userId:user.id, entries:res.hits.hits}

    save:        (user, entry) ->

    clients:     (user, start, stop) ->

    projects:    (user, start, stop) ->

    saveproject: (user, project) ->
