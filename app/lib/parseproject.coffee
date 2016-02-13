{ucase, match, pipe, converge, join, always, maybe, unapply, at} = require 'fnuc'

grok = pipe ucase, match /([A-Z]{3})([0-9]+)/
pad  = (s) -> if s.length < 4 then pad("0#{s}") else s

module.exports = fn =
    maybe pipe grok, maybe converge at(1), pipe(at(2), pad), unapply(join '')

# expose to reuse
fn.grok = grok
