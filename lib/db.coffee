mongodb = require 'mongodb'

class Db
  constructor: (@host, @port, @database, @collection) ->
    server = new mongodb.Server @host, @port
    @db = new mongodb.Db @database, server
    @db.open (err, db) =>
      db.createCollection(@collection, (err, collection) ->
        collection.ensureIndex({hostname: 1})
        collection.ensureIndex({app: 1})
        collection.ensureIndex({time: -1})
      )
    @results = []

  insert: (item) ->
    @db.collection @collection, (err, col) ->
      throw err if err
      try
        col.insert item
      catch error
        console.error error
        return

  getCollection: () -> @db.collection(@collection)

  find: (conditions = {}) -> this.getCollection().find conditions

exports.db = Db
