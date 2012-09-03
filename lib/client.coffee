fs = require 'fs'
http = require 'http'
querystring = require 'querystring'
url = require 'url'
  
# "\n"
LINE_BREAK = 10

class Client
  constructor: (@app, @api = {}, @currentPosition = 0) ->
    @file = @app.file
    @hostname = require('os').hostname()
    unless fs.existsSync(@file)
      throw new Error("File #{@file} doesn't exists.")

  # open log file
  openFile: () ->
    @filesize = fs.statSync(@file).size
    @fd = fs.openSync @file, 'r'

  # read a line
  readLineSync: (position) ->
    return null if position >= @filesize

    line = ''
    @currentPosition = position
    while true
      buffer = new Buffer(1)
      fs.readSync @fd, buffer, 0, 1, @currentPosition
      if @currentPosition >= @filesize or buffer[0] == LINE_BREAK
        @currentPosition += 1
        break

      line += buffer.toString()

      @currentPosition += 1

    line.trim()

  # process new logs 
  process: (callback) ->
    this.openFile()
    finishedLines = 0
    while true
      line = this.readLineSync(@currentPosition)
      break if line is null
      time = this.getTimeOf(line) || (new Date()).getTime()
      logLevel = callback(line)
      continue if logLevel is null

      this.push(logLevel, time, line) if @api.url

      finishedLines += 1

    fs.closeSync @fd
    @fd = null
    finishedLines

  # push a log to elog server
  push: (level, time, line) ->
    params = {
      '_id': this.md5(line),
      'app': @app.name,
      'hostname': @hostname,
      'time': time,
      'msg': line,
      'level': level
    }
    log = JSON.stringify(params)
    data = querystring.stringify {"log": log}
    uri = url.parse @api.url + "/#{@api.key}"
    http_options = {
      'host': uri.hostname,
      'port': uri.port,
      'path': uri.path,
      'method': 'POST',
      'headers': {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': data.length
      }
    }
    hr = http.request http_options, (res) ->
      res.setEncoding('utf8')
      res.on 'data', (chunk) ->
        console.log chunk if chunk != 'OK'

    hr.on 'error', (error) ->
      console.log "[#{new Date().toString()}] elog-server error: #{error}"

    hr.write data
    hr.end()

  # get time of one line log 
  getTimeOf: (line) ->
    regs = [
      /^\[(.+?)\]/, # php error logs
      /^(.+?)\s+\[/, # nginx error logs
      /\[(.+?)\]/ # nginx & apache access logs
    ]
    for reg in regs
      time = null
      matches = line.match(reg)
      if matches
        # fixing nginx/apache access logs
        time = new Date(matches[1].replace(/(\d{4}):(\d{2})/, '$1 $2')).getTime()
        return time if time and time.toString() isnt "NaN"

    null

  md5: (str) ->
    require('crypto').createHash('md5').update(str).digest('hex')

exports.client = Client
