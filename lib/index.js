var util = require('util')
  , events = require('events')
  , debug = require('debug')('walkingdead')
  , Zombie = require('zombie')
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
    cb = (typeof cb === 'function' ? cb : noop);
    self.walk(url, cb);
  };

  /**
   * begins the walking proces if it hasn't already started
   */

  this.onWalk = function () {
    debug('onWalk');
    if (this.walking()) return;
    function next () {
      var path = self.paths().shift();
      debug('next', typeof path, path ? path.url : undefined);
      if (!path) return self.emit('done');
      self.emit('walking', path.url);
      path(function evaluate (err, zombie, status) {
        debug('evaluate', err, typeof zombie, status);
        if (err) self.emit('error', err, path.url, zombie, status);
        self.emit('walked', path.url, zombie, status);
        next();
      });
    }
    next();
  };

  this.on('walk', this.onWalk);

  /**
   * Called when we are walking a url
   *
   * @param {String} url
   */

  this.onWalking = function (url) {
    debug('onWalking', url);
    self._walking = true;
  };

  this.on('walking', this.onWalking);

  /**
   * Called when we have walked a url
   *
   * @param {String} url
   * @param {Zombie} zombie
   * @param {mixed} status
   */

  this.onWalked = function (url, zombie, status) {
    debug('onWalked', url, typeof zombie, status);
    self._walking = self.paths().length ? true : false;
  };

  this.on('walked', this.onWalked);

  /**
   * Called when we get an error
   *
   * @param {Error} err
   * @param {String} url
   * @param {Zombie} zombie
   * @param {mixed} status
   */

  this.onError = function (err, url, zombie, status) {
    debug('onError', err, url, typeof zombie, status);
    console.error(err);
  };

  this.on('error', this.onError);

  this._walking = false;
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
  if (!this._paths) {
    this._paths = [];
  }
  return this._paths;
};

/**
 * Produces a function that will go into the path our zombie is walking
 *
 * @param {String} url
 * @param {Function} cb *optional
 * @return Function
 */

WalkingDead.prototype.path = function (url, cb) { 
  debug('path', url, typeof cb);
  var self = this;
  function begin (next) {
    debug('begin ', url, typeof cb, typeof next);
    self.process(url, function processed (err, zombie, status) {
      debug('processed', err, typeof zombie, status);
      next(err, zombie, status); 
      if (typeof cb === 'function') cb(err, zombie, status);
    });
  };
  begin.url = url;
  return begin;
};

/**
 * processes the url
 *
 * @param {String} url
 * @param {Function} cb
 * @return WalkingDead
 */

WalkingDead.prototype.process = function (url, cb) {
  debug('process', url, typeof cb);
  this.zombie().visit(url, cb);
};

/**
 * Gets the zombie instance
 *
 * @return Zombie
 */

WalkingDead.prototype.zombie = function () {
  debug('zombie');
  if (!this._zombie) {
    this._zombie = new Zombie();
  }
  return this._zombie;
};

/**
 * Determines if we are walking
 *
 * @return boolean
 */

WalkingDead.prototype.walking = function () {
  debug('walking', this._walking);
  return this._walking;
};

function noop () { debug('noop'); }
