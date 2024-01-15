package blok.tower.generate;

import blok.html.Client;
import blok.tower.asset.*;
import blok.tower.asset.document.ClientDocument;
import blok.tower.client.HistoryTools;
import blok.tower.config.Config;
import blok.tower.core.*;
import blok.tower.routing.Navigator;
import kit.http.Request;

class ClientTarget implements Target {
  final container:Container;
  final config:Config;
  final renderer:Renderer;
  final assetFactory:AssetContextFactory;

  public function new(container, config, renderer, assetFactory) {
    this.container = container;
    this.config = config;
    this.renderer = renderer;
    this.assetFactory = assetFactory;
  }

  public function run():Cancellable {
    var document = new ClientDocument({ root: config.render.root });
    var assets = assetFactory.createAssetContext(document);
    var root = hydrate(
      document.getRoot(),
      () -> renderer.render(
        () -> {
          var nav = new Navigator({ 
            request: {
              request: new Request(Get, getLocation()),
              isPopState: false
            } 
          });
          var link = bindNavigatorToBrowserHistory(nav);
          nav.addDisposable(() -> link.cancel());
          nav;
        }, 
        () -> new AppContext(container, assets, config)
      )
    );

    return () -> root.dispose(); 
  }
}
