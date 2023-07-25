package blok.tower.server.middleware;

import kit.http.Handler.HandlerObject;
import blok.tower.routing.ApiRouteCollection;
import kit.http.*;

class ApiRouterMiddleware implements Middleware {
  final routes:ApiRouteCollection;
  
  public function new(routes) {
    this.routes = routes;
  }

  public function apply(handler:Handler):Handler {
    return new ApiRouterMiddlewareHandler(routes, handler);
  }
}

class ApiRouterMiddlewareHandler implements HandlerObject {
  final routes:ApiRouteCollection;
  final handler:Handler;

  public function new(routes, handler) {
    this.routes = routes;
    this.handler = handler;
  }

  public function process(request:Request):kit.Future<Response> {
    return switch routes.match(request) {
      case Some(res): res;
      case None: handler.process(request); 
    }
  }
}
