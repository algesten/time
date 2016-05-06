B1;95;0ccerts = require '../google-oauth-certs'
jwt   = require 'jsonwebtoken'
log   = require 'bog'

options =
    issuer:   'https://accounts.google.com'
    audience: process.env.AUTH_GOOGLE_AUDIENCE_ID
    algorithms: [ 'RS256','RS384','RS512','ES256','ES384','ES512' ]

module.exports = (token) ->

    # expect a string to decode
    return 400 unless typeof token == 'string' and token

    # decode without verifying the signature
    decoded = jwt.decode token, complete:true

    # no entity decoded?!
    return 400 unless decoded

    # to get the key id
    kid = decoded.header.kid

    # and the corresponding cert
    cert = certs[kid]

    # no such cert?!
    unless cert
        log.warn 'Missing cert for key id:', kid
        return 417 # Expectation failed

    # certificate is verified
    try
        jwt.verify token, cert, options
    catch err
        if err.name == 'TokenExpiredError'
            return 422 # Unprocessable Entity
        log.warn 'Failed to verify cert for:', decoded, err
        return 400

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
