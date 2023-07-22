package blok.tower.routing;

import kit.http.*;

class ApiRouteCollection implements ApiRoute {
  final routes:Array<ApiRoute>;
  
  public function new(routes) {
    this.routes = routes;
  }

  public function add(route:ApiRoute) {
    if (!routes.contains(route)) routes.push(route);
  }
  
  public function addRoutes(routes:Array<ApiRoute>) {
    for (route in routes) add(route);
  }

  public function test(request:Request):Bool {
    for (route in routes) if (route.test(request)) return true;
    return false;
  }

  public function match(request:Request):Maybe<Future<Response>> {
    for (route in routes) switch route.match(request) {
      case Some(response):
        return Some(response);
      case None:
    }
    return None;
  }
}
