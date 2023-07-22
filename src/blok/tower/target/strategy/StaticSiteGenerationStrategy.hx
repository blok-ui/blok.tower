package blok.tower.target.strategy;

import blok.tower.asset.*;
import blok.tower.core.*;
import blok.tower.data.HydrationId;
import blok.tower.target.Visitor;

/**
  Static site generation strategy.

  Will output the entire site as static files, including all resources.
**/
class StaticSiteGenerationStrategy implements Strategy {
  final container:Container;
  final appFactory:AppRootFactory;
  final visitor:Visitor;
  final logger:Logger;
  final output:Output;
  final hydrationId:HydrationId;

  public function new(container, appFactory, visitor, logger, output, hydrationId) {
    this.container = container;
    this.appFactory = appFactory;
    this.visitor = visitor;
    this.logger = logger;
    this.output = output;
    this.hydrationId = hydrationId;
  }

  public function run():Cancellable {
    logger.log(Info, 'Generating site...');
    var generator = new Generator(container, appFactory, output, visitor, logger, StaticSiteGeneratedTarget, hydrationId);
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
