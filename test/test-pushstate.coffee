syspath = require  'path'

pushstate = require '../lib/pushstate'

describe.only 'pushstate', ->

    it 'exports the normalized in parameters as .ndirs', ->
        mw = pushstate ['a', './a', '../a', '/a']
        cwd = process.cwd()
        eql mw.ndirs, [
            "#{cwd}/a"
            "#{cwd}/a"
            syspath.normalize "#{cwd}/../a"
            "/a"
        ]
