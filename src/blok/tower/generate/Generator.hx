package blok.tower.generate;

import blok.context.Provider;
import blok.html.Server;
import blok.suspense.*;
import blok.tower.asset.*;
import blok.tower.asset.document.StaticDocument;
import blok.tower.config.*;
import blok.tower.core.*;
import blok.tower.routing.Navigator;
import haxe.Timer;
import kit.http.Request;

class Generator {
  final container:Container;
  final config:Config;
  final output:Output;
  final renderer:Renderer;
  final assetContextFactory:AssetContextFactory;
  final visitor:Visitor;
  final logger:Logger;
  final coreAssets:AssetBundle;

  public function new(container, config, output, renderer, assetContextFactory, visitor, logger, coreAssets) {
    this.container = container;
    this.config = config;
    this.output = output;
    this.renderer = renderer;
    this.assetContextFactory = assetContextFactory;
    this.visitor = visitor;
    this.logger = logger;
    this.coreAssets = coreAssets;
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
    var document:Document = new StaticDocument({ root: config.render.root });
    var assets = assetContextFactory.createAssetContext(document);
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
        ]).child(_ -> renderer.render(
          () -> new Navigator({ 
            request: {
              request: new Request(Get, path),
              isPopState: false 
            }
          }),
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
