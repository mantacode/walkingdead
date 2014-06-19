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

  var self = this;

  events.EventEmitter.call(this);
  options = options || {};
  options.agents = options.agents || [];
  this.options = options;

  /**
   * Attach this method to an EventEmitter to trigger
   * the walk() action.
   */

  this.onUrl = function (url) {
    self.walk(url);
  };
}

util.inherits(WalkingDead, events.EventEmitter);

/**
 * Walk the page
 */

WalkingDead.prototype.walk = function (url) {
};
