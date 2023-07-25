package blok.tower.server;

import kit.http.*;

class MiddlewareCollection implements Middleware {
  final middlewares:Array<Middleware>;

  public function new(middlewares) {
    this.middlewares = middlewares;
  }

  public function add(middleware:Middleware) {
    middlewares.push(middleware);
  }

  public function apply(handler:Handler):Handler {
    var mws = middlewares.copy();
    var mw = mws.pop();

    while (mw != null) {
      handler = mw.apply(handler);
      mw = mws.pop();
    }

    return handler;
  }
}
