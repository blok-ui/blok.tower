package blok.tower.routing;

import blok.ui.*;

class ViewRouter extends Component {
  @:constant final navigator:Navigator = null;
  @:constant final routes:ViewRouteCollection;

  function render() {
    return switch routes.match(Navigator.from(this).request()) {
      case Some(node):
        node;
      case None: 
        throw new RoutingError(NotFound, 'Route not found');
    }
  }
}
