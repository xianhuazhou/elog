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
}
