exports.elog = {
  LOG_FATAL: 4,
  LOG_ERROR: 3,
  LOG_WARN: 2,
  LOG_INFO: 1,
  LOG_DEBUG: 0,

  db: require('./db.coffee').db,
  client: require('./client.coffee').client,
  mclient: require('./mclient.coffee').mclient,
  server: require('./server.coffee').server,
  utils: require('./utils.coffee').utils

  kill: (program, opts = '', output) ->
    exec = require('child_process').exec
    exec("kill #{opts} `ps -ef | grep #{program} | grep -v grep | awk '{print $2}'`", (error, stdout, stderr) ->
      if error
        console.log "Error: #{error}"
        process.exit 1
      stdout.print output
    )
    process.exit 0

  reload: (program) ->
    console.log "Reloading #{program} ..."
    this.kill program, '-HUP', "Reload #{program} finished.\n"

  stop: (program) ->
    console.log "Stopping #{program} ..."
    this.kill program, '', "Stop #{program} finished.\n"
}
