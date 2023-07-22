package blok.tower.routing;

import blok.ui.*;

class PageVisitor extends Component {
  @:constant final to:String;
  @:constant final onUsed:()->Void = null;
  @:constant final child:(goToPage:()->Void)->Child;

  function render() {
    return child(() -> {
      switch Navigator.maybeFrom(this) {
        case None:
        case Some(nav): nav.go(to);
      }
      if (onUsed != null) onUsed();
    });
  }

  #if (!blok.tower.client)
  function setup() {
    switch blok.tower.target.VisitorContext.maybeFrom(this) {
      case Some(visitor): visitor.get().visit(to);
      case None:
    }
  }
  #end
}
