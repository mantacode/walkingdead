
exec = require('child_process').exec

describe 'walking dead', ->

  Given -> @command = __dirname + '/../../bin/walkingdead.js'

  When (done) ->
    exec @command, (err, stdout, stderr) =>
      if err?
        console.error err
        done err
      else
        @stdout = stdout
        done()

  Then -> expect(@stdout).toEqual "The walking dead!\n"

