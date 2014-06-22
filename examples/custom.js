var urls = ['http://www.manta.com', 'https://www.npmjs.org/search?q=mantacode', 'http://www.github.com/mantacode'];

var options = { userAgents: ['walkingdead/1.0'] };
var dead = require('./..')(options);
dead.on('walk', function () { console.log('walking urls!'); });
dead.on('walking', function (url, ua) { console.log('walking "%s" with "%s"', url, ua) });
dead.on('walked', function (url, ua, zombie, status) { console.log('walked "%s" with "%s" and the status is %s"', url, ua, status) });
dead.on('done', function () { console.log('we require more urls!') });
dead.on('error', function (err) { console.error('oops "%s"!', err) });

(function feed () {
  var url = urls.shift();
  if (!url) return console.log('done');
  dead.walk(url, function () {
    feed();
  });
})();
