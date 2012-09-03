elog = require('../lib/elog.coffee').elog
fs = require 'fs'
path = require 'path'
express = require 'express'

describe 'Client', ->
  describe 'functions', ->

    file1 = path.join(__dirname, "data", "test.log")
    config = {
      'apps': [
        {
          'name': 'app name',
          'file': file1,
          'rules': [
            [/error/i, elog.LOG_ERROR],
            [/info/i, elog.LOG_INFO]
          ]
        }
      ],
      'api': {
        'key': 'apikey',
        'url': 'http://localhost:2228/api'
      }
    }
    
    beforeEach(->
      data = "[2012-03-04 11:11:22] error, message\n"
      data += "[2012-03-05 10:33:22] notice, message\n"
      data += "[2012-03-06 11:22:22] error, message\n"
      data += "[2012-03-07 03:10:29] info, message"
      fs.writeFileSync(file1, data, "utf-8")
    )

    afterEach(->
      fs.unlinkSync file1
    )

    it 'should read a line from a specified position', ->
      line_one = "[2012-03-04 11:11:22] error, message"
      line_two = "[2012-03-05 10:33:22] notice, message"

      client = new elog.client(config.apps[0])
      client.openFile()
      line = client.readLineSync 0
      line.should.equal line_one

      line = client.readLineSync line_one.length + 1
      line.should.equal line_two

    it 'can process lines with callback', ->
      client = new elog.client(config.apps[0])

      numberOfLines = client.process (line) ->
        for rule in config.apps[0].rules
          return rule[1] if rule[0].test(line)

        null
      numberOfLines.should.equal 3

    it 'can do a real process', ->
      client = new elog.client(config.apps[0], config.api)

      app = express()
      app.use express.bodyParser()
      app.post '/api/apikey', (req, res) ->
        log = JSON.parse(req.body.log)
        log.app.should.equal 'app name'
        log.time.should.equal (new Date('2012-03-07 03:10:29')).getTime()
        log.msg.should.equal '[2012-03-07 03:10:29] info, message'
        log.level.should.equal elog.LOG_INFO
        res.send 'OK'
      app.listen 2228, 'localhost'

      client.process (line) ->
        if /info/.test(line)
          elog.LOG_INFO
        else
          null

    it 'can get time from a line', ->
      client = new elog.client(config.apps[0])

      # php error logs style
      time = client.getTimeOf("[2012-03-04 11:11:22] error, message")
      (new Date('2012-03-04 11:11:22')).getTime().should.equal time

      # nginx error logs style
      time = client.getTimeOf("2012-03-04 11:11:22 [error], message")
      (new Date('2012-03-04 11:11:22')).getTime().should.equal time

      # nginx & apache access logs style
      time = client.getTimeOf('127.0.0.1 - - [27/Aug/2012:11:05:58 +0800] "GET / HTTP/1.1"')
      (new Date('27/Aug/2012 11:05:58 +0800')).getTime().should.equal time
