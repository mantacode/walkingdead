exports = module.exports = WalkingDead;
exports.version = require('./../package.json').version;

function WalkingDead (options) {
  if (!(this instanceof WalkingDead)) return new WalkingDead(options);
  options = options || {};
  options.agents = options.agents || [];
  this.options = options;
}
