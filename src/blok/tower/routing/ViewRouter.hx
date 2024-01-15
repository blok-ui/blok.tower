package blok.tower.routing;

import blok.ui.*;

class ViewRouter extends Component {
  @:attribute final navigator:Navigator = null;
  @:attribute final routes:ViewRouteCollection;

  function isNestedRouter() {
    return findAncestorOfType(ViewRouter).map(_ -> true).or(false);
  }

  function render() {
    var nav = Navigator.from(this);
    return switch routes.match(nav.request().request) {
      case Some(node):
        node;
      case None if (isNestedRouter()):
        null;
      case None: 
        throw new RoutingError(NotFound, 'Route not found');
    }
  }
}
