http = require 'http'
util = require 'util'
ejs = require 'ejs'
utils = require('./utils.coffee').utils

# a simple web server of elog working with MongoDB
class Server
  constructor: (@config, db) ->
    @db = new db(
      config.mongodb.host,
      config.mongodb.port,
      config.mongodb.database,
      config.mongodb.collection
    )

  # run the web server
  run: () ->
    express = require 'express'
    app = express()

    # app config
    app.set('config', @config)
    app.set('db', @db)
    app.set 'view engine', 'ejs'
    app.set 'views', __dirname + '/../views'
    app.use express.static(__dirname + '/../views')
    app.use express.bodyParser()

    app.get '/', (req, res) ->
      webConfig = app.get('config').web
      query = req.query
      res.set('Content-Type', 'text/html; charset=UTF-8')
      limit = query.limit || webConfig.limit_per_page
      apps = query.apps || ''
      hosts = query.hosts || ''
      startDate = query.startDate || ''
      endDate = query.endDate || ''

      conditions = {}
      conditions['app'] = {$in: apps.split(/,\s*/)} if apps
      conditions['hostname'] = {$in: hosts.split(/,\s*/)} if hosts

      if startDate
        startDateObj = new Date(startDate)
        if (utils.isValidDate(startDateObj))
          conditions['time'] = {$gte: startDateObj.getTime()}

      if endDate
        endDateObj = new Date(endDate)
        if (utils.isValidDate(endDateObj))
          conditions['time'] = {$lte: endDateObj.getTime()}

      app.get('db').find(conditions).sort({time: -1}).limit(+limit).toArray (err, docs) ->
        res.render 'index', {
          docs: docs,
          title: webConfig.title || 'elog homepage',
          currentLimit: limit,
          currentApps: apps,
          currentHosts: hosts,
          currentStartDate: startDate,
          currentEndDate: endDate,
          refreshTime: webConfig.refresh_time
        }

    app.post '/api/:api_key', (req, res) ->
      res.set('Content-Type', 'text/plain')
      if req.params.api_key != app.get('config').api_key
        return res.send("KO")

      doc = JSON.parse(req.body.log)
      console.log doc
      app.get('db').insert doc
      res.send "OK"

    console.log "elog-server is running at #{@config.http.port}"
    @app = app.listen(@config.http.port, @config.http.host)

  shutdown: () ->
    console.log "Closing server."
    @app.close()
    @app = null

exports.server = Server
