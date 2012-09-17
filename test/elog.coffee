elog = require('../lib/elog.coffee').elog
db = elog.db

describe 'elog', ->
  describe 'updateServer', ->
    config = {
      "mongodb": {
        "port": 27017,
        "host": "localhost",
        "database": "elogtest",
        "collection": "logs"
      }
    }

    mongoDB = null
    cfg = config.mongodb
    mongoDB = new elog.db(cfg.host, cfg.port, cfg.database, cfg.collection, false)

    mongoDB.db.open (err, db) ->
      db.createCollection(cfg.collection, (err, collection) ->
        collection.insert({
          hostname: 'hostname',
          app: 'app',
          level: 3,
          time: new Date().getTime(),
          dupid: 'blablamd5'
        }, {safe: true}, (err, docs) ->
          console.log err if err
        )
      )

    afterEach(->
      mongoDB.getCollection().drop()
    )

    it "can create indexes", ->
      elog.updateServer(config)
      mongoDB.getCollection().indexInformation (err, doc) ->
        indexes = []
        indexes.push(k) for k, v of doc
        indexes.should.include '_id_'
        indexes.should.include 'hostname'
        indexes.should.include 'app'
        indexes.should.include 'level'
        indexes.should.include 'time'
        indexes.should.include 'dupid'
