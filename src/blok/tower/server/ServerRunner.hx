package blok.tower.server;

import kit.http.*;
import kit.http.Server;
import blok.tower.cli.Process;
import blok.tower.core.Logger;

class ServerRunner {
  final server:Server;
  final logger:Logger;
  var handler:Handler;

  public function new(server, logger, middleware:MiddlewareCollection, rootHandler) {
    this.server = server;
    this.logger = logger;
    this.handler = middleware.apply(rootHandler);
  }

  public function run() {
    serve().handle(status -> switch status {
      case Failed(e): 
        logger.log(Error, 'Failed to start server');
        Sys.exit(1);
      case Running(close):
        logger.log(Info, 'Serving app on localhost:8080');
        Process.registerCloseHandler(() -> {
          logger.log(Info, 'Closing server...');
          close(_ -> {
            logger.log(Info, 'Server closed');
          });
        });
      case Closed:
        Sys.exit(0);
    });
  }

  public function with(middleware:Middleware):ServerRunner {
    handler = middleware.apply(handler);
    return this;
  }

  public function serve():Future<ServerStatus> {
    return server.serve(handler);
  }
}