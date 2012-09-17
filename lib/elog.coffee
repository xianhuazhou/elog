path = require 'path'
fs = require 'fs'

# main
exports.elog = {
  LOG_FATAL: 4,
  LOG_ERROR: 3,
  LOG_WARN: 2,
  LOG_INFO: 1,
  LOG_DEBUG: 0,

  VERSION: "0.0.2",

  db: require('./db.coffee').db,
  client: require('./client.coffee').client,
  mclient: require('./mclient.coffee').mclient,
  server: require('./server.coffee').server,
  utils: require('./utils.coffee').utils,

  checkArgv: (argv, program) ->
    this.reload(program) if argv is 'reload'
    this.stop(program) if argv is 'stop'
    this.showConfig(program) if argv is 'show-config'
    this.showVersion() if argv is '-v' or argv is '--version'
    if argv is 'reset-positions' and program is 'elog-client'
      fs.unlinkSync positionFile
      process.exit 0

  kill: (program, opts = '', output) ->
    exec = require('child_process').exec
    exec("kill #{opts} `ps -ef | grep #{program} | grep -v grep | awk '{print $2}'`", (error, stdout, stderr) ->
      if error
        console.log "Error: #{error}"
        process.exit 1
      stdout.print output
    )
    process.exit 0

  updateServer: (config) ->
    console.log "Updating elog-server ..."
    cfg = config.mongodb
    utils = this.utils
    myDB = new this.db(cfg.host, cfg.port, cfg.database, cfg.collection, false)
    myDB.open (collection, db) ->
      collection = db.collection(cfg.collection)
      console.log "   >> updating indexes"
      myDB.createIndexes()
      collection.find().toArray (err, docs) ->
        console.log "   >> updating dupids for show top X errors"
        for doc in docs
          return unless doc
          updatedData = {dupid: utils.md5(utils.trimLineTime(doc.msg))}
          collection.update({_id: doc._id}, {$set: updatedData})

        console.log ""
        console.log "elog-server has been updated."
        process.exit 0

  reload: (program) ->
    console.log "Reloading #{program} ..."
    this.kill program, '-HUP', "Reload #{program} finished.\n"

  stop: (program) ->
    console.log "Stopping #{program} ..."
    this.kill program, '', "Stop #{program} finished.\n"

  showVersion: () ->
    console.log "version: %s", this.VERSION
    process.exit 0

  showConfig: (program) ->
    configFile = path.join(__dirname, '..', 'etc', "#{program.split('-')[1]}.json")
    console.log fs.readFileSync(configFile, 'utf8')
    process.exit 0
}
