fs = require 'fs'
util = require 'util'
$timers = []

# just wrap elog.client
class MClient
  constructor: (@config, @elog, @positionFile, @positionData) ->

  # reate RegExp from a string or an array
  # possible parameters: 
  #  "error", "notice", ["error", "i"], ["Fatal", "i"] ...
  createRegexp: (regex) ->
    if util.isArray(regex)
      new RegExp(regex[0], regex[1])
    else
      new RegExp(regex)

  # filter line by the given rules, 
  # return a log level if the line is matched by the rules 
  filterLine: (line, rules) ->
    for exclude in rules.exclude
      return null if this.createRegexp(exclude).test(line)

    for include in rules.include
      if this.createRegexp(include[0]).test(line)
        return @elog[include[1]]

    null

  run: () ->
    elog = @elog
    positionData = @positionData
    positionFile = @positionFile
    self = this

    for app in @config.apps
      position = positionData[app.name] || app.position || 0
      console.log "Processing #{app.name} at position #{position} ..."
      client = new elog.client(app, app.api || @config.api, position)

      do (client) ->
        $timers.push setInterval(() ->
          # don't process it if there is one is still running
          return if client.fd

          # process logs line by line
          client.process((line) -> self.filterLine line, app.rules)

          positionData[client.app.name] = client.currentPosition
          fs.writeFileSync positionFile, JSON.stringify(positionData)

        , app.interval_time)

  shutdown: () ->
    for timer in $timers
      console.log "Clear interval: #{timer}"
      clearInterval timer

exports.mclient = MClient
