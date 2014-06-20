var util = require('util')
  , events = require('events')
  , debug = require('debug')('walkingdead')
  ;

exports = module.exports = WalkingDead;
exports.version = require('./../package.json').version;

/**
 * A WalkingDead object will walk a URL with zombie
 *
 * @param {Object} options
 * @return WalkingDead
 */

function WalkingDead (options) {
  debug('creating instance with these options: ', options);
  if (!(this instanceof WalkingDead)) {
    debug('this not an instanceof WalkingDead');
    return new WalkingDead(options);
  }

  var self = this;

  events.EventEmitter.call(this);
  options = options || {};
  options.agents = options.agents || [];
  this.options = options;

  /**
   * Attach this method to an EventEmitter to trigger
   * the walk() action.
   *
   * @param {String} url
   * @param {Function} cb
   */

  this.onUrl = function (url, cb) {
    debug('onUrl', url, typeof cb);
    self.walk(url);
  };

  /**
   * begins the walking proces if it hasn't already started
   */

  this.onWalk = function () {
    debug('onWalk');
  };

  this.on('walk', this.onWalk);
}

util.inherits(WalkingDead, events.EventEmitter);

/**
 * Queues a job to walk the url
 *
 * @api public
 * @param {String} url
 * @param {Function} cb
 * @return WalkingDead
 */

WalkingDead.prototype.walk = function (url, cb) {
  debug('walk', url, typeof cb);
  this.paths().push(this.path(url, cb));
  this.emit('walk');
  return this;
};

/**
 * Initializes the paths
 *
 * @return Array
 */

WalkingDead.prototype.paths = function () { 
  debug('paths');
};

/**
 * Produces a function that will go into the path our zombie is walking
 *
 * @param {String} url
 * @param {Function} cb
 * @return Function
 */

WalkingDead.prototype.path = function (url, cb) { 
  debug('path', url, typeof cb);
};
