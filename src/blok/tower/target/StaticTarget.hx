package blok.tower.target;

import blok.tower.core.*;

class StaticTarget implements Target {
  final generator:Generator;
  final logger:Logger;

  public function new(generator, logger) {
    this.generator = generator;
    this.logger = logger;
  }

  public function run():Cancellable {
    logger.log(Info, 'Generating site...');
    return generator.generate().handle(o -> switch o {
      case Ok(_):
        logger.log(Info, 'Generation successful.');
        Sys.exit(0);
      case Error(error):
        logger.log(Error, 'Failed to generate site.');
        logger.log(Error, 'Encountered error with code: ${error.code} and message: ${error.message}');
        Sys.exit(1);
    });
  }
}
