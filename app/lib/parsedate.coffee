{match, head, tail} = require 'fnuc'
moment = require 'moment'

# pCUqRwDoQnAAr4CznTAwJRpwUhoCc2

# (<date>|t|y|yy|yyyy|day)

# t      - today
# y      - 1 day backward (yesterday)
# yy     - 2 days backward (day before yesterday)
# [y]+   - n days ago
# w      - 1 week ago
# ww     - 2 weeks ago
# [w]+   - n weeks ago
# d      - 1 day forward
# dd     - 2 days forward
# [d]+   - n days forward

loc = ->
    dateexp: /^w?[\/0-9]+/
    relexp:  /t?[ydw]+/
    formats: ['DD', '[w]WW', 'MMDD', 'DD/MM', 'YYMMDD', 'YYYYMMDD']
    offsets: {t:0, y:-1, d:1, w:-7}

asUTC = (s) -> new Date "#{s}Z"
torel = (offsets) -> _torel = (s) ->
    if s.length then offsets[head(s)] + _torel(tail(s)) else 0


module.exports = parsedate = (s) ->
    return null unless s
    l = loc() # TODO: i18n
    [sdate] = match(s, l.dateexp) ? ['']
    [srel]  = match(s[sdate.length..], l.relexp) ? ['']
    return null if sdate == '0' # edge case that moment treats badly
    m       = if sdate then moment(sdate, l.formats) else moment()
    date    = asUTC m.format 'YYYY-MM-DD'
    rel     = torel(l.offsets) srel
    moment(date).add(rel, 'days').toDate()
