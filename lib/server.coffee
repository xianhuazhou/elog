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
      apps = query.apps || []
      hosts = query.hosts || []
      levels = query.levels || []
      startDate = query.startDate || ''
      endDate = query.endDate || ''

      conditions = {}
      conditions['app'] = {$in: apps} if apps.length > 0
      conditions['hostname'] = {$in: hosts} if hosts.length > 0
      conditions['level'] = {$in: levels} if levels.length > 0

      if startDate
        startDateObj = new Date(startDate)
        if (utils.isValidDate(startDateObj))
          conditions['time'] = {$gte: startDateObj.getTime()}

      if endDate
        endDateObj = new Date(endDate)
        if (utils.isValidDate(endDateObj))
          conditions['time'] = {$lte: endDateObj.getTime()}

      db = app.get('db')
      collection = db.getCollection()
      collection.distinct 'hostname', (err, allHosts) ->
        console.log "[#{new Date()}] MongoDB error: #{err}" if err

        collection.distinct 'level', (err, allLevels) ->
          console.log "[#{new Date()}] MongoDB error: #{err}" if err

          collection.distinct 'app', (err, allApps) ->
            console.log "[#{new Date()}] MongoDB error: #{err}" if err

            db.find(conditions).sort({time: -1}).limit(+limit).toArray (err, docs) ->
              console.log "[#{new Date()}] MongoDB error: #{err}" if err
              res.render 'index', {
                docs: docs,
                allApps: allApps,
                allHosts: allHosts,
                allLevels: allLevels,
                title: webConfig.title || 'elog homepage',
                currentLimit: limit,
                currentApps: apps,
                currentHosts: hosts,
                showSelectOptions: utils.showSelectOptions,
                currentLevels: levels,
                currentStartDate: startDate,
                currentEndDate: endDate,
                refreshTime: webConfig.refresh_time
              }

    app.get '/newlogs', (req, res) ->
      query = req.query
      apps = query.apps || []
      hosts = query.hosts || []
      levels = query.levels || []
      conditions = {}
      conditions['app'] = {$in: apps} if apps.length > 0
      conditions['hostname'] = {$in: hosts} if hosts.length > 0
      conditions['level'] = {$in: level} if levels.length > 0
      conditions['time'] = {$gt: +req.query.time}
      app.get('db').find(conditions).sort({time: -1}).toArray (err, docs) ->
        console.log "[#{new Date()}] MongoDB error: #{err}" if err
        res.render 'logs', {
          docs: docs,
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
