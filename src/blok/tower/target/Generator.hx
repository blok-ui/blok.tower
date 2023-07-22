package blok.tower.target;

import haxe.Timer;
import blok.tower.data.HydrationId;
import blok.context.Provider;
import blok.html.server.Server.mount;
import blok.suspense.*;
import blok.tower.asset.*;
import blok.tower.asset.document.StaticDocument;
import blok.tower.core.*;
import kit.http.Request;

class Generator {
  final container:Container;
  final appFactory:AppRootFactory;
  final output:Output;
  final visitor:Visitor;
  final logger:Logger;
  final target:Target;
  final hydrationId:HydrationId;

  public function new(container, appFactory, output, visitor, logger, target, hydrationId) {
    this.container = container;
    this.appFactory = appFactory;
    this.output = output;
    this.visitor = visitor;
    this.logger = logger;
    this.target = target;
    this.hydrationId = hydrationId;
  }

  public function generate() {
    return generateAll().next(_ -> {
      var stamp = Timer.stamp();
      logger.log(Info, '...all pages visited, outputting assets...');
      output.process().next(_ -> {
        var time = Std.string(Math.ceil((Timer.stamp() - stamp) * 1000));
        time = time.substr(0, 4);
        logger.log(Info, '...assets processed in ${time}ms');
        Nothing;
      });
    });
  }

  function generateAll():Task<Nothing> {
    visitor.visit('/');
    return new Task(activate -> {
      generateNext(() -> activate(Ok(Nothing)), e -> activate(Error(e)));
    });
  }

  function generateNext(resume:()->Void, recover:(error:Error)->Void) {
    return visitor.drain(generatePage).handle(o -> switch o {
      case Ok(_) if (visitor.hasPending()):
        generateNext(resume, recover);
      case Ok(_):
        resume();
      case Error(error):
        recover(error);
    });
  }

  function generatePage(path:String):Task<Document> {
    var document:Document = new StaticDocument();
    var container = container.getChild();
    var assets = new AssetContext(output, document, hydrationId, target);
    var wasSuspended:Bool = false;
    var completed:Bool = false;
    var stamp = Timer.stamp();

    function getTime() {
      var time = Std.string(Math.ceil((Timer.stamp() - stamp) * 1000));
      time = time.substr(0, 4);
      return  '${time}ms';
    }

    logger.log(Info, '...visiting $path');

    return new Task(activate -> {
      mount(
        document.getRoot(),
        () -> Provider.compose([
          () -> new VisitorContext(visitor),
          () -> new SuspenseBoundaryContext({
            onSuspended: () -> {
              wasSuspended = true;
            },
            onComplete: () -> {
              if (completed) {
                throw 'onComplete was triggered more than once for $path';
              }
              completed = true;
              logger.log(Info, '...page loaded in ${getTime()}: $path');
              activate(Ok(document));
            }
          })
        ], _ -> appFactory.create(
          new Request(Get, path),
          () -> new AppContext(container, assets)
        ))
      );

      if (!wasSuspended) {
        completed = true;
        logger.log(Info, '...page loaded in ${getTime()}: $path');
        activate(Ok(document));
      }
    }).next(document -> {
      assets.add(new HtmlAsset({
        path: path,
        content: document.toString()
      }));
      document;
    });
  }
}
