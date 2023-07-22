package blok.tower.target;

import blok.tower.target.Strategy;

// @todo: It would be nice not to have this, but we need it
// to force a dependency on Strategy.
class StrategyResolver {
  final strategy:Strategy;

  public function new(strategy) {
    this.strategy = strategy;
  }
  
  public function get() {
    return strategy;
  }
}
