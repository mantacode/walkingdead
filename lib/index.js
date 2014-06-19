var util = require('util')
  , events = require('events')
  ;

exports = module.exports = WalkingDead;
exports.version = require('./../package.json').version;

/**
 * A WalkingDead object will walk a URL with zombie
 *
 * @return WalkingDead
 */

function WalkingDead (options) {
  if (!(this instanceof WalkingDead)) return new WalkingDead(options);
  events.EventEmitter.call(this);
  options = options || {};
  options.agents = options.agents || [];
  this.options = options;
}

util.inherits(WalkingDead, events.EventEmitter);
