#!/usr/bin/env node

var fs = require('fs')
  , split = require('split')
  , debug = require('debug')('app')
  , WalkingDead = require('./..')
  , app = require('commander')
  , steps = []
  ;

app
  .version(WalkingDead.version)
  .usage('[options]')
  .option('-a, --agents <string>', 'path to a file of user-agents')
  .parse(process.argv);

steps.push(function (path, next) {
  debug('get agents', path, typeof next);
  var agents = [];
  if (!path) return next(null, agents);
  fs.createReadStream(path)
    .pipe(split())
    .on('data', function (line) { agents.push(line) })
    .on('error', next)
    .on('close', function () { next(null, agents) });
});

steps.push(function (agents, next) {
  debug('get dead', agents, typeof next);
  next(null, WalkingDead({agents: agents}));
});

steps.push(function (dead, next) {
  debug('get urls', dead, typeof next);
  dead.on('done', next);
  process.stdin.pipe(split()).on('data', function (data) {
    debug('data %s', data);
    dead.walk(data);
  });
});

(function next(data) {
  var step = steps.shift();
  if (!step) return;
  step(data, function cb (err, data) {
    debug('cb', err, data);
    if (err) throw err;
    next(data); 
  });
})(app.agents);

