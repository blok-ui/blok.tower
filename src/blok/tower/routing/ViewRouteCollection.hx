package blok.tower.routing;

import blok.ui.VNode;
import kit.http.Request;

class ViewRouteCollection implements ViewRoute {
  final routes:Array<ViewRoute>;
  
  public function new(routes) {
    this.routes = routes;
  }

  public function add(route:ViewRoute) {
    if (!routes.contains(route)) routes.push(route);
  }
  
  public function addRoutes(routes:Array<ViewRoute>) {
    for (route in routes) add(route);
  }

  public function test(request:Request):Bool {
    for (route in routes) if (route.test(request)) return true;
    return false;
  }

  public function match(request:Request):Maybe<VNode> {
    for (route in routes) switch route.match(request) {
      case Some(node):
        return Some(node);
      case None:
    }
    return None;
  }
}
