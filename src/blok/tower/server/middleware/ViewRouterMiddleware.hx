package blok.tower.server.middleware;

import kit.http.Handler.HandlerObject;
import blok.tower.generate.Generator;
import kit.http.*;

class ViewRouterMiddleware implements Middleware {
  final generator:Generator;

  public function new(generator) {
    this.generator = generator;
  }

  public function apply(handler:Handler):Handler {
    return new ViewRouterMiddlewareHandler(generator, handler);
  }
}

class ViewRouterMiddlewareHandler implements HandlerObject {
  final generator:Generator;
  final handler:Handler;

  public function new(generator, handler) {
    this.generator = generator;
    this.handler = handler;
  }

  public function process(request:Request):kit.Future<Response> {
    return generator.generateSinglePage(request.url).next(document -> {
      return new Response(OK, [
        new HeaderField(ContentType, 'text/html')
      ], document.toString());
    }).recover(_ -> handler.process(request));
  }
}
