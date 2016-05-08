request = require 'request'

URL = "https://www.googleapis.com/oauth2/v1/certs"

module.exports = -> new Promise (rs, rj) -> request URL, (err, res, body) ->
    return rj(err) if err
    return rj("status #{res.statusCode}") unless res.statusCode == 200
    try
        rs JSON.parse body
    catch err
        rj(err)
