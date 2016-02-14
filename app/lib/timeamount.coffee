HOURS =   60 * 60
MINUTES = 60

pad = (n) -> if n <= 9 then "0#{n}" else "#{n}"

module.exports = (t) ->
    hours   = Math.floor(t / HOURS)
    minutes = Math.floor((t % HOURS) / MINUTES)
    "#{pad hours}:#{pad minutes}"
