package blok.tower.server;

import blok.tower.cli.Process;
import blok.tower.config.Config;
import blok.tower.core.Logger;
import kit.http.*;
import kit.http.Server;

class ServerRunner {
  final config:Config;
  final server:Server;
  final logger:Logger;
  var handler:Handler;

  public function new(config, server, logger, middleware:MiddlewareCollection, rootHandler) {
    this.config = config;
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
        logger.log(Info, 'Serving app on localhost:${config.server.port}');
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