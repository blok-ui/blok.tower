package blok.tower.server.middleware;

import blok.tower.core.Logger;
import kit.http.*;
import kit.http.Handler;

class LoggerMiddleware implements Middleware {
  final logger:Logger;
  
  public function new(logger) {
    this.logger = logger;
  }

	public function apply(handler:Handler):Handler {
    return new LoggerMiddlewareHandler(handler, logger);
	}
}

class LoggerMiddlewareHandler implements HandlerObject {
  final handler:Handler;
  final logger:Logger;

  public function new(handler, logger) {
    this.handler = handler;
    this.logger = logger;
  }

	public function process(req:Request):Future<Response> {
    // @todo: Log other things too?
		return handler.process(req).map(response -> {
      req.extract({ url: url });
      response.extract({ status: code });
      logger.log(switch code {
        case OK: Info;
        default: Error;
      }, 'Matched $url with code $code');
      response;
    });
	}
}
