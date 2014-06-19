exports = module.exports = WalkingDead;
exports.version = require('./../package.json').version;

function WalkingDead () {
  if (!(this instanceof WalkingDead)) return new WalkingDead();
}
