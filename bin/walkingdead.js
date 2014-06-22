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
  if (path.match(/^\.{1,2}\//) || path.charAt(0) !== '/') {
    path = process.cwd() + '/' + path;
  }
  fs.stat(path, function (err, stat) {
    if (err) return next(err);
    if (!stat.isFile()) return next(new Error('path must be a file.'));
    next(null, path);
  });
});

steps.push(function (path, next) {
  debug('get agents', path, typeof next);
  var agents = [];
  if (!path) return next(null, agents);
  fs.createReadStream(path)
    .pipe(split())
    .on('data', function (line) { if (line.length) agents.push(line) })
    .on('error', next)
    .on('close', function () { next(null, agents) });
});

steps.push(function (agents, next) {
  debug('get dead', agents, typeof next);
  next(null, WalkingDead({agents: agents}));
});

steps.push(function (dead, next) {
  debug('get urls', dead, typeof next);
  dead.on('walking', function (url, ua) { console.log('walking "%s" with "%s"', url, ua); });
  dead.on('done', function() { next() });
  process.stdin.pipe(split()).on('data', function (data) {
    debug('data %s', data);
    if (data.length) dead.walk(data);
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

