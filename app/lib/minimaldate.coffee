{iif, always, pipe, eq} = require 'fnuc'
moment = require 'moment'

{today} = require './datefun'

mtoday = -> moment(today()).utcOffset(0)

notsame = (f) -> (tim) -> mtoday().format(f) != tim.format(f)
diff    = (t) -> (tim) -> mtoday().diff(tim, t)
format  = (f) -> (t) -> t.format f

daydiff = (n) -> pipe diff('day'), eq(n)

module.exports =
    iif notsame('YYYY'),   format('YYMMDD'),
    iif notsame('YYYYMM'), format('MMDD'),
    iif daydiff(3), always('yyy'),
    iif daydiff(2), always('yy'),
    iif daydiff(1), always('y'),
    iif daydiff(0), always('t'), format('DD')
