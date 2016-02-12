{ucase, match, pipe, maybe, at} = require 'fnuc'

grok = match /([A-Z]{3})/

module.exports =
    maybe pipe ucase, grok, maybe at(1)
