{iif, always} = require 'fnuc'

diff   = (t1, t) -> (t2) -> t1.diff(t2, t)
format = (f) -> (t) -> t.format f

module.exports = (t1) ->
    iif diff(t1, 'year'),  format('YYMMDD'),
    iif diff(t1, 'month'), format('MMDD'),
    iif diff(t1, 'day'),   format('DD'), always('t')
