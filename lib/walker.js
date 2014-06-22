var util = require('util')
  , events = require('events')
  , debug = require('debug')('walker')
  , Zombie = require('zombie')
  ;

module.exports = Walker;

/**
 * A Walker object will walk a URL with zombie
 *
 * @param {Object} options
 * @return Walker
 */

function Walker (options) {
  debug('Walker', options);
  if (!(this instanceof Walker)) {
    debug('not an instance');
    return new Walker(options);
  }

  events.EventEmitter.call(this);

  var self = this;

  options = options || {};
  options.agents = options.agents || [];
  this.options = options;

  /**
   * Attach this method to an EventEmitter to trigger
   * the walk() action.
   *
   * @api public
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
    if (self.walking()) return;
    self.emit('walk');
    function next () {
      try {
        var path = self.paths().shift();
        debug('next', (typeof path, path ? path.url : undefined), (typeof path, path ? path.ua : undefined));
        if (!path) return self.emit('done');
        self.onWalking(path.url, path.ua);
        path(function evaluate (err, zombie, status) {
          try {
            debug('evaluate', err, typeof zombie, status);
            if (err) return self.onError(err, path.url, path.ua, zombie, status);
            self.onWalked(path.url, path.ua, zombie, status, next);
            next();
          }
          catch(e) {
            self.onError(e, (path ? path.url : null), (path ? path.ua : null), self.zombie(), status);
          }
        });
      }
      catch(e) {
        self.onError(e, (path ? path.url : null), (path ? path.ua : null), self.zombie(), null);
      }
    }
    next();
  };

  /**
   * Called when we are walking a url
   *
   * @param {String} url
   * @param {String} ua
   */

  this.onWalking = function (url, ua) {
    debug('onWalking', url, ua);
    self._walking = true;
    self.emit('walking', url, ua);
  };

  /**
   * Called when we have walked a url
   *
   * @param {String} url
   * @param {String} ua
   * @param {Zombie} zombie
   * @param {mixed} status
   */

  this.onWalked = function (url, ua, zombie, status) {
    debug('onWalked', url, ua, typeof zombie, status);
    self._walking = self.paths().length ? true : false;
    self.emit('walked', url, ua, zombie, status);
  };

  /**
   * Called when we get an error
   *
   * @param {Error} err
   * @param {String} url
   * @param {String} ua
   * @param {Zombie} zombie
   * @param {mixed} status
   */

  this.onError = function (err, url, ua, zombie, status) {
    debug('onError', err, url, ua, typeof zombie, status);
    console.error(err);
    self.emit('error', err, url, ua, zombie, status);
  };

  this._walking = false;
}

util.inherits(Walker, events.EventEmitter);

/**
 * Queues a job to walk the url
 *
 * @api public
 * @param {String} url
 * @param {Function} cb
 * @return Walker
 */

Walker.prototype.walk = function (url, cb) {
  debug('walk', url, typeof cb);
  var agents = this.options.agents || [];
  if (!agents.length) agents.push(this.zombie().userAgent);
  for (var i=0; i<agents.length; i++) this.paths().push(this.path(url, agents[i], cb));
  this.onWalk();
  return this;
};

/**
 * Initializes the paths
 *
 * @return Array
 */

Walker.prototype.paths = function () { 
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
 * @param {String} ua
 * @param {Function} cb *optional
 * @return Function
 */

Walker.prototype.path = function (url, ua, cb) { 
  debug('path', url, typeof cb);
  var self = this;
  function begin (next) {
    debug('begin ', url, ua, typeof cb, typeof next);
    self.process(url, ua, function processed (err, zombie, status) {
      debug('processed', err, typeof zombie, status);
      next(err, zombie, status); 
      if (typeof cb === 'function') cb(err, zombie, status);
    });
  };
  begin.url = url;
  begin.ua = ua;
  return begin;
};

/**
 * Tells the zombie to vist the url and pass it's result in the callback 
 *
 * @param {String} url
 * @param {String} ua
 * @param {Function} cb
 * @return Walker
 */

Walker.prototype.process = function (url, ua, cb) {
  debug('process', url, ua, typeof cb);
  var zombie = this.zombie();
  zombie.userAgent = ua;
  zombie.visit(url, cb);
};

/**
 * Gets the zombie instance
 *
 * @return Zombie
 */

Walker.prototype.zombie = function () {
  debug('zombie');
  if (!this._zombie) {
    this._zombie = new Zombie();
  }
  return this._zombie;
};

/**
 * Determines if we are walking
 *
 * @api public
 * @return boolean
 */

Walker.prototype.walking = function () {
  debug('walking', this._walking);
  return this._walking;
};

function noop () { debug('noop'); }
