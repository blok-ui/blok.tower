package blok.tower.routing;

import blok.ui.*;

class ViewRouter extends Component {
  @:constant final navigator:Navigator = null;
  @:constant final routes:ViewRouteCollection;

  function isNestedRouter() {
    // @todo: This works, but it's kinda a hack and I think reveals that
    // our routing system maybe needs some work?
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
