package blok.tower.generate;

import blok.debug.Debug;
import blok.context.Context;

@:fallback(error('No VisitorContext exists'))
class VisitorContext implements Context {
  final visitor:Visitor;

  public function new(visitor) {
    this.visitor = visitor;
  }

  public function get() {
    return this.visitor;
  }

  public function dispose() {
    // noop 
  }
}
