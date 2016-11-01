
module.exports = entry:properties:
    userId:
        type:  'keyword'
    date:
        type:  'date'
    modified:
        type:  'date'
    title:
        type:  'text'
        fielddata: true
    time:
        type:  'long'
    clientId:
        type:  'keyword'
    projectId:
        type:  'keyword'
    orig:
        type:  'keyword'
