
toiso = (d) -> d?.toISOString()
today = -> asutc new Date()
now   = -> toiso new Date()
asutc = (date) ->
    d = date.toISOString()[0...10]
    new Date "#{d}T00:00:00Z"

module.exports = {toiso, today, now, asutc}
