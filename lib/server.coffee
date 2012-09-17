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
    self = this

    # app config
    app.set('config', @config)
    app.set('db', @db)
    app.set 'view engine', 'ejs'
    app.set 'views', __dirname + '/../views'
    app.use express.static(__dirname + '/../views')
    app.use express.bodyParser()

    self.routeRoot app
    self.routeNewlogs app
    self.routeApi app

    console.log "elog-server is running at #{@config.http.port}"
    @app = app.listen(@config.http.port, @config.http.host)

  # build conditions from query params 
  buildConditions: (query) ->
    apps = this.queryApps(query)
    hosts = this.queryHosts(query)
    levels = this.queryLevels(query)

    conditions = {}
    conditions['app'] = {$in: apps} if apps.length > 0
    conditions['hostname'] = {$in: hosts} if hosts.length > 0
    conditions['level'] = {$in: levels} if levels.length > 0

    if query.time
      conditions['time'] = {$gt: +query.time}
      return conditions

    startDate = this.queryStartDate(query)
    endDate = this.queryEndDate(query)

    if startDate
      startDateObj = new Date(startDate)
      if (utils.isValidDate(startDateObj))
        conditions['time'] = {$gte: startDateObj.getTime()}

    if endDate
      endDateObj = new Date(endDate)
      if (utils.isValidDate(endDateObj))
        conditions['time'] = {$lte: endDateObj.getTime()}

    conditions

  queryApps: (query) -> query.apps || []
  queryHosts: (query) -> query.hosts || []
  queryLevels: (query) -> (query.levels || []).map((it) -> +it)
  queryStartDate: (query) -> query.startDate || ''
  queryEndDate: (query) -> query.endDate || ''

  routeRoot: (app) ->
    self = this
    app.get '/', (req, res) ->
      webConfig = app.get('config').web
      query = req.query
      res.set('Content-Type', 'text/html; charset=UTF-8')
      limit = query.limit || webConfig.limit_per_page

      conditions = self.buildConditions query

      # fetch logs
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
                currentApps: self.queryApps(query),
                currentHosts: self.queryHosts(query),
                currentLevels: self.queryLevels(query),
                currentStartDate: self.queryStartDate(query),
                currentEndDate: self.queryEndDate(query),
                refreshTime: webConfig.refresh_time,

                # helper functions from utils
                utils: utils
              }

  routeNewlogs: (app) ->
    self = this
    app.get '/newlogs', (req, res) ->
      conditions = self.buildConditions req.query
      app.get('db').find(conditions).sort({time: -1}).toArray (err, docs) ->
        console.log "[#{new Date()}] MongoDB error: #{err}" if err
        res.render 'logs', {
          docs: docs,
          utils: utils
        }

  routeApi: (app) ->
    app.post '/api/:api_key', (req, res) ->
      res.set('Content-Type', 'text/plain')
      if req.params.api_key != app.get('config').api_key
        return res.send("KO")

      doc = JSON.parse(req.body.log)
      console.log doc
      app.get('db').insert doc
      res.send "OK"

  shutdown: () ->
    console.log "Closing server."
    @app.close()
    @app = null

exports.server = Server
