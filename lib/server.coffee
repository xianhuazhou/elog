http = require 'http'
util = require 'util'
ejs = require 'ejs'
utils = require('./utils.coffee').utils

# a simple web server of elog working with MongoDB
class Server
  constructor: (@config, @db) ->
    cfg = @config.mongodb
    @myDB = new @db(
      cfg.host,
      cfg.port,
      cfg.database,
      cfg.collection
    )

  # run the web server
  run: () ->
    express = require 'express'
    app = express()

    # app config
    app.set('config', @config)
    app.set 'view engine', 'ejs'
    app.set 'views', __dirname + '/../views'
    app.use express.static(__dirname + '/../views')
    app.use express.bodyParser()

    this.routeRoot app
    this.routeNewlogs app
    this.routeApi app

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
      collection = self.myDB.getCollection()
      collection.distinct 'hostname', (err, allHosts) ->
        utils.dbError "#{err} [routeRoot:distinct#hostname]" if err

        collection.distinct 'level', (err, allLevels) ->
          utils.dbError "#{err} [routeRoot:distinct#level]" if err

          collection.distinct 'app', (err, allApps) ->
            utils.dbError "#{err} [routeRoot:distinct#app]" if err

            collection.find(conditions).sort({time: -1}).limit(+limit).toArray (err, docs) ->
              utils.dbError "#{err} [routeRoot:find]" if err
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
      self.myDB.find(conditions).sort({time: -1}).toArray (err, docs) ->
        utils.dbError "#{err} [routeNewlogs]" if err
        res.render 'logs', {
          docs: docs,
          utils: utils
        }

  routeApi: (app) ->
    self = this
    app.post '/api/:api_key', (req, res) ->
      res.set('Content-Type', 'text/plain')
      if req.params.api_key != app.get('config').api_key
        return res.send("KO")

      doc = JSON.parse(req.body.log)
      self.myDB.insert doc
      res.send "OK"

  shutdown: () ->
    console.log "Closing server."
    @app.close()
    @app = null

exports.server = Server
