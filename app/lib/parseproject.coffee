{ucase, match, pipe, converge, join, always, maybe, unapply, at} = require 'fnuc'

grok = match /([A-Z]{3})([0-9]+)/
pad  = (s) -> if s.length < 4 then pad("0#{s}") else s

module.exports =
    maybe pipe ucase, grok, maybe converge at(1), pipe(at(2), pad), unapply(join '')
