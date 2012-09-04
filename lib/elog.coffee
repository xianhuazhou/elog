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

  reload: (program) ->
    console.log "Reloading #{program} ..."
    exec = require('child_process').exec
    exec("kill -HUP `ps aux | grep #{program} | grep -v grep | awk '{print $2}'`", (error, stdout, stderr) ->
      if error
        console.log "Error: #{error}"
        process.exit 1
      stdout.print "Reload #{program} finished.\n"
    )
    process.exit 0
}
