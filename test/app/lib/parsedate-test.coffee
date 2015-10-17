{each, always} = require 'fnuc'
moment = require 'moment'

parsedate = require '../../../app/lib/parsedate'

forday = do ->
    cur = -> (new Date()).toISOString()[0...7]
    (d) -> -> new Date "#{cur()}-#{d}Z"

formonth = do ->
    cur = -> (new Date()).toISOString()[0...4]
    (m, d) -> -> new Date "#{cur()}-#{m}-#{d}Z"

foryear = (y, m, d) -> -> new Date "#{y}-#{m}-#{d}Z"

forweek = do ->
    cur = -> (new Date()).toISOString()[0...4]
    (w) -> -> moment("#{cur()} #{w} Z", "YYYY WW Z").toDate()

today = do ->
    cur = -> (new Date()).toISOString()[0...10]
    -> new Date "#{cur()}Z"

describe 'parsedate', ->

    it "parses '' to null", ->
        eql parsedate(''), null

    locales = [
        n: 'default'
        date: [
            ['0',  'null',                            always(null)]
            ['1',  'the first of current month',      forday(1)]
            ['13', 'the thirteenth of current month', forday(13)]
            ['w9', 'week 9 of current year',          forweek(9)]
            ['12/1', 'jan 12 of current year',        formonth(1,12)]
            ['0112', 'jan 12 of current year',        formonth(1,12)]
            ['140112', 'jan 12 of 2014',              foryear(2014,1,12)]
            ['20140112', 'jan 12 of 2014',            foryear(2014,1,12)]
        ]
        rel: [
            ['d',   'one day after',      1]
            ['dd',  'two days after',     2]
            ['y',   'one day before',    -1]
            ['yy',  'two days before',   -2]
            ['w',   'one week before',   -7]
            ['wd',  'six days before',   -6]
            ['wy',  'eight days before', -8]
        ]
    ]

    each locales, (l) -> describe "in #{l.n} locale", ->

        describe 'with date', ->

            describe 'and no relative,', -> each l.date, (dt) ->
                exp = dt[0]
                it "parses '#{exp}' as #{dt[1]}", ->
                    eql parsedate(exp), dt[2]()

            describe 'and relative,', -> each l.date, (dt) -> each l.rel, (rt) ->
                exp = dt[0] + rt[0]
                start = dt[2]()
                date = moment(start).add(rt[2], 'days').toDate() if start
                words = if date then "#{rt[1]} #{dt[1]}" else "null"
                it "parses '#{exp}' as #{words}", ->
                    eql parsedate(exp), date ? null

        describe 'without date', ->

            each l.rel, (rt) ->
                exp = rt[0]
                start = today()
                date = moment(start).add(rt[2], 'days').toDate()
                it "parses '#{exp}' as #{rt[1]} today", ->
                    eql parsedate(exp), date

            it "parses 't' as today", ->
                eql parsedate('t'), today()
