desc 'Run test'
task 'test', (params) ->
  testCMD = 'mocha -r should --compilers coffee:coffee-script'
  require('child_process').exec testCMD, (error, stdout, stderr) ->
    console.log stdout
    console.log error if error
