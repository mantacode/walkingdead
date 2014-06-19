exports = module.exports = WalkingDead;
exports.version = require('./../package.json').version;

/**
 * A WalkingDead object will walk a URL with zombie
 *
 * @return WalkingDead
 */

function WalkingDead (options) {
  if (!(this instanceof WalkingDead)) return new WalkingDead(options);
  options = options || {};
  options.agents = options.agents || [];
  this.options = options;
}
