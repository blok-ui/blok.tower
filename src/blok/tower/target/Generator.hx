package blok.tower.target;

import blok.context.Provider;
import blok.html.server.Server.mount;
import blok.suspense.*;
import blok.tower.asset.*;
import blok.tower.asset.document.StaticDocument;
import blok.tower.config.*;
import blok.tower.core.*;
import blok.tower.data.HydrationId;
import blok.tower.routing.Navigator;
import blok.tower.target.compile.ClientAppCompiler;
import haxe.Timer;
import kit.http.Request;

class Generator {
  final container:Container;
  final config:Config;
  final appFactory:AppRootFactory;
  final output:Output;
  final visitor:Visitor;
  final logger:Logger;
  final hydrationId:HydrationId;

  public function new(container, config, appFactory, output, visitor, logger, hydrationId) {
    this.container = container;
    this.config = config;
    this.appFactory = appFactory;
    this.output = output;
    this.visitor = visitor;
    this.logger = logger;
    this.hydrationId = hydrationId;
  }

  public function generate():Task<Nothing> {
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

  public function generateSinglePage(path:String):Task<Document> {
    return generatePage(path).next(document -> {
      var stamp = Timer.stamp();
      logger.log(Info, '...page generated, outputting assets...');
      output.process().next(_ -> {
        var time = Std.string(Math.ceil((Timer.stamp() - stamp) * 1000));
        time = time.substr(0, 4);
        logger.log(Info, '...assets processed in ${time}ms');
        document;
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
    var assets = new AssetContext(output, config, document, hydrationId);
    var wasSuspended:Bool = false;
    var completed:Bool = false;
    var stamp = Timer.stamp();

    function getTime() {
      var time = Std.string(Math.ceil((Timer.stamp() - stamp) * 1000));
      time = time.substr(0, 4);
      return  '${time}ms';
    }

    // @todo: Dunno if this is the best place for this.
    assets.add(new ClientAppCompiler(config));
    #if !blok.tower.pre_configured
    assets.add(new ConfigAsset());
    #end

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
          () -> new Navigator({ request: new Request(Get, path) }),
          () -> new AppContext(container, assets, config)
        ))
      );

      if (!wasSuspended) {
        completed = true;
        logger.log(Info, '...page loaded in ${getTime()}: $path');
        activate(Ok(document));
      }
    }).next(document -> {
      if (config.type.shouldOutputHtml()) assets.add(new HtmlAsset({
        path: path,
        content: document.toString()
      }));
      document;
    });
  }
}
