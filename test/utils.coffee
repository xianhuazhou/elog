elog = require('../lib/elog.coffee').elog
utils = elog.utils

describe 'Utils', ->
  describe 'showSelectOptions', ->

    it 'should show a select drop down', ->
      allApps = ['App1', 'App2', 'App3']
      currentApps = []
      name = 'apps'
      utils.showSelectOptions(name, allApps, currentApps).should.include 'name="apps[]"'

    it 'should show with selected option', ->
      allApps = ['App1', 'App2', 'App3']
      currentApps = ['App2']
      name = 'apps'
      utils.showSelectOptions(name, allApps, currentApps).should.include '<option value="App2" selected="selected">'

