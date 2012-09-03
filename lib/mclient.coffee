fs = require 'fs'
$timers = []

# just wrap elog.client
class MClient
  constructor: (@config, @elog, @positionFile, @positionData) ->

  run: () ->
    elog = @elog
    positionData = @positionData
    positionFile = @positionFile

    for app in @config.apps
      position = positionData[app.name] || app.position || 0
      console.log "Processing #{app.name} at position #{position} ..."
      client = new elog.client(app, app.api || @config.api, position)

      do (client) ->
        $timers.push setInterval(() ->
          # don't process it if there is one is still running
          return if client.fd

          # process logs
          client.process((line) ->
            for rule in app.rules
              return elog[rule[1]] if new RegExp(rule[0]).test(line)
            null
          )
          positionData[client.app.name] = client.currentPosition
          fs.writeFileSync positionFile, JSON.stringify(positionData)

        , app.interval_time)

  shutdown: () ->
    for timer in $timers
      console.log "Clear interval: #{timer}"
      clearInterval timer

exports.mclient = MClient
