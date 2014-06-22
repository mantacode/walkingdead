
exec = require('child_process').exec

describe 'walking dead', ->

  Given -> @command = __dirname + '/../../bin/walkingdead.js -a spec/uas.txt < ' + __dirname + '/urls.txt'

  When (done) ->
    exec @command, (err, stdout, stderr) =>
      if err?
        console.error err
        done err
      else
        @stdout = stdout
        done()

  Then -> expect(@stdout).toBe([
    'walking "http://localhost:3000/the" with "the/1.0"',
    'walking "http://localhost:3000/the" with "dead/1.0"',
    'walking "http://localhost:3000/the" with "walk/1.0"',
    'walking "http://localhost:3000/dead" with "the/1.0"',
    'walking "http://localhost:3000/dead" with "dead/1.0"',
    'walking "http://localhost:3000/dead" with "walk/1.0"',
    'walking "http://localhost:3000/walk" with "the/1.0"',
    'walking "http://localhost:3000/walk" with "dead/1.0"',
    'walking "http://localhost:3000/walk" with "walk/1.0"'
  ].join("\n")+"\n")
