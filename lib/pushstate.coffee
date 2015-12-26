{map, reduce, merge, iif, always, concat, fold, typeis} = require 'fnuc'
syspath = require 'path'
{normalize, join} = syspath
fs  = require 'fs'
log = require 'bog'

rooted = (d) ->
    root = if d[0] == '/' then '' else process.cwd()
    normalize join root, d

isstring = typeis 'string'

stat = (p) -> new Promise (rs, rj) -> fs.stat p, (err, ret) -> if err then rj(err) else rs(ret)

alwaysp = (v) -> always Promise.resolve v

module.exports = pushstate = (dirs) ->

    # normalized dirs to serve files from
    ndirs = map dirs, rooted

    merge (req, res, next) ->

        {path} = req

        patterns = [
            "#{path}",
            "#{path}/index.html",
            "#{path}.html",
            "/index.html"
            ]

        # files to attempt in the order to attempt them
        attempts = concat (map patterns, (p) -> map ndirs, (d) ->
            # ensure no ../ above root
            if (a = normalize join d, p).indexOf(d) == 0 then a else null
        .filter (a) -> !!a)...

        # find the first existing file
        result = fold(Promise.resolve 404) attempts, (p, c) -> p.then (code) ->
            return code unless code == 404 # propagate through
            stat(c).then (st) ->
                if st.isFile() then c else 404
            , (err) ->
                if err.code == 'ENOENT' then 404 else Promise.reject(err)

        # ret is either a response code or a string file path
        result.then (ret) ->
            if isstring(ret) then res.sendFile(ret) else res.status(ret)
        , (err) ->
            log.error 'pushstate serving failed', err

    , {ndirs}
