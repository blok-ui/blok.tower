package blok.tower.target;

import blok.tower.core.Logger;
import blok.tower.server.ServerRunner;

class DynamicTarget implements Target {
  final server:ServerRunner;
  final generator:Generator;
  final logger:Logger;

  public function new(server, generator, logger) {
    this.server = server;
    this.generator = generator;
    this.logger = logger;
  }

  public function run():Cancellable {
    logger.log(Info, 'Visiting pages to process assets...');
    return generator.generate().handle(o -> switch o {
      case Ok(_):
        logger.log(Info, 'Asset processing successful. Starting server...');
        server.run();
      case Error(error):
        logger.log(Error, 'Failed to process assets.');
        logger.log(Error, 'Encountered error with code ${error.code} and message: ${error.message}');
        Sys.exit(1);
    });
  }
}
