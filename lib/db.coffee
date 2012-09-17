mongodb = require 'mongodb'
utils = require('./utils.coffee').utils

class Db
  constructor: (@host, @port, @database, @collection, open = true) ->
    server = new mongodb.Server @host, @port, {auto_reconnect: true}
    @db = new mongodb.Db @database, server
    this.open() if open

  open: (callback = null) ->
    @db.open (err, db) =>
      utils.dbError "#{err} [openDB]" if err
      db.createCollection @collection, (err, collection) ->
        utils.dbError "#{err} [createCollection]" if err
        callback collection, db if callback

  insert: (item) ->
    try
      this.getCollection().insert item, (err, docs) =>
        utils.dbError "#{err} [insert]" if err
        console.log docs[0]

    catch error
      console.error error
      return

  getCollection: () ->
    @db.collection(@collection)

  createIndexes: () ->
    collection = this.getCollection()
    collection.ensureIndex({hostname: 1})
    collection.ensureIndex({app: 1})
    collection.ensureIndex({level: 1})
    collection.ensureIndex({time: -1})
    collection.ensureIndex({dupid: 1})

  find: (conditions = {}) ->
    this.getCollection().find conditions

exports.db = Db
