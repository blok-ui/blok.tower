package blok.tower.routing;

import blok.ui.*;

class PageVisitor extends Component {
  @:attribute final to:String;
  @:attribute final onUsed:()->Void = null;
  @:attribute final child:(goToPage:()->Void)->Child;

  function render() {
    return child(() -> {
      switch Navigator.maybeFrom(this) {
        case Some(nav): nav.go(to);
        case None:
      }
      if (onUsed != null) onUsed();
    });
  }

  #if !blok.tower.client
  function setup() {
    switch blok.tower.generate.VisitorContext.maybeFrom(this) {
      case Some(visitor): visitor.get().visit(to);
      case None:
    }
  }
  #end
}
