package blok.tower.routing;

import blok.ui.*;

class ViewRouter extends Component {
  @:attribute final navigator:Navigator = null;
  @:attribute final routes:ViewRouteCollection;

  function isNestedRouter() {
    return findAncestorOfType(ViewRouter).map(_ -> true).or(false);
  }

  function render() {
    return switch routes.match(Navigator.from(this).request()) {
      case Some(node):
        node;
      case None if (isNestedRouter()):
        null;
      case None: 
        throw new RoutingError(NotFound, 'Route not found');
    }
  }
}
