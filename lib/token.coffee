getcerts = require './getcerts'
jwt      = require 'jsonwebtoken'
log      = require 'bog'

OPTS =
    issuer:   'https://accounts.google.com'
    audience: process.env.AUTH_GOOGLE_AUDIENCE_ID
    algorithms: [ 'RS256','RS384','RS512','ES256','ES384','ES512' ]

decode = (token) ->

    # expect a string to decode
    throw 400 unless typeof token == 'string' and token

    # decode without verifying the signature
    decoded = jwt.decode token, complete:true

    # no entity decoded?!
    throw 400 unless decoded

    decoded


certfor = (decoded) -> getcerts().then (certs) ->

    # to get the key id
    kid = decoded.header.kid

    # and the corresponding cert
    cert = certs[kid]

    # no such cert?!
    unless cert
        log.warn 'Missing cert for key id:', kid
        throw 417 # Expectation failed

    cert


verify = (token, cert, decoded) ->

    try
        jwt.verify token, cert, OPTS
    catch err
        if err.name == 'TokenExpiredError'
            throw 422 # Unprocessable Entity
        log.warn 'Failed to verify cert for:', decoded, err
        throw 400


module.exports = (token) ->

    # decode the token without verifying
    Promise.resolve(token).then(decode).then (decoded) ->

        # grab the latest set of certs and verify
        certfor(decoded).then (cert) -> verify token, cert, decoded

    .then ->

        # at this point decoded is also verified
        pay = decoded.payload

        # make a similar structure to what we get if we do a
        # passport auth
        # { id: '110994664963851875523',
        #   displayName: 'Martin Algesten',
        #   name: { familyName: 'Algesten', givenName: 'Martin' },
        #   emails: [ { value: 'martin@algesten.se', type: 'account' } ]
        # }
        {
            id: pay.sub
            displayName: pay.name
            name: { familyName: pay.family_name, givenName:pay.given_name }
            emails: [ { value:pay.email, type:'account' } ]
        }
