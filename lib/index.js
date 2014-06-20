var util = require('util')
  , events = require('events')
  , debug = require('debug')('walkingdead')
  , Walker = require('./walker')
  ;

exports = module.exports = WalkingDead;
exports.version = require('./../package.json').version;

/**
 * A WalkingDead object exposes a public api to Walker
 *
 * @param {Object} options
 * @return WalkingDead
 */

function WalkingDead (options) {
  debug('WalkingDead', options);
  if (!(this instanceof WalkingDead)) {
    debug('not an instance');
    return new WalkingDead(options);
  }
  events.EventEmitter.call(this);
  this.walker = Walker(options);
}

util.inherits(WalkingDead, events.EventEmitter);

/*
 * Expose the public API
 */

debug('Walker.prototype', Object.keys(Walker.prototype));

['onUrl', 'walk', 'walking'].forEach(function (name) {
  debug('attaching "%s" to prototype', name);
  debug('Walker.prototype["%s"] exists? %s', name, Walker.prototype[name] ? true : false);
  debug('Walker.prototype.%s', name, typeof Walker.prototype[name]);
  WalkingDead.prototype[name] = function () {
    debug('calling %s', name);
    Walker.prototype[name].apply(this.walker, Array.prototype.slice.call(arguments));
    return this;
  };
});

/*
 * Delegate to the walker
 */
  
Object.keys(events.EventEmitter.prototype).forEach(function (name){
  debug('attaching "%s" to prototype', name);
  debug('EventEmitter.prototype["%s"] exists? %s', name, events.EventEmitter.prototype[name] ? true : false);
  debug('EventEmitter.prototype.%s', name, typeof Walker.prototype[name]);
  WalkingDead.prototype[name] = function () {
    debug(name);
    return events.EventEmitter.prototype[name].apply(this.walker, Array.prototype.slice.call(arguments));
  };
});

WalkingDead.prototype.__defineGetter__('listenerCount', function () { return this.walker.listenerCount; });
