package blok.tower.core;

import blok.ui.VNode;

@:forward
@:callable
abstract AppRoot((router:VNode)->VNode) from (router:VNode)->VNode {
  inline public function new(root) {
    this = root;
  }
}
