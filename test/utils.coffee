elog = require('../lib/elog.coffee').elog
utils = elog.utils

describe 'Utils', ->
  describe 'isValidDate', ->
    it 'can validate date', ->
      utils.isValidDate(new Date()).should.be.true
      utils.isValidDate(new Date('2011-13-13')).should.be.false
      utils.isValidDate(new Date('blabla')).should.be.false

  describe 'capitalize', ->
    it 'can capitalize the first character of a string', ->
      utils.capitalize('hello').should.equal 'Hello'
      utils.capitalize('DATA').should.equal 'DATA'

  describe 'showSelectOptions', ->
    it 'should show a select drop down', ->
      allApps = ['App1', 'App2', 'App3']
      currentApps = []
      name = 'apps'
      utils.showSelectOptions(name, allApps, currentApps).should.include 'name="apps[]"'
      utils.showSelectOptions(name, allApps, currentApps).should.include '>Apps<'

    it 'should show with selected option', ->
      allApps = ['App1', 'App2', 'App3']
      currentApps = ['App2']
      name = 'ppa'
      utils.showSelectOptions(name, allApps, currentApps).should.include '<option value="App2" selected="selected">'
      utils.showSelectOptions(name, allApps, currentApps).should.include '>Ppa<'

    it 'should work with callback', ->
      allApps = [4, 3, 2, 1, 0]
      currentApps = [3]
      name = 'Level'
      selectOptions = utils.showSelectOptions(name, allApps, currentApps, (levelId) ->
        elog.getLevelById(levelId)
      )
      selectOptions.should.include '>Fatal<'
      selectOptions.should.include '>Error<'
      selectOptions.should.include '>Warning<'
      selectOptions.should.include '>Info<'
      selectOptions.should.include '>Debug<'
