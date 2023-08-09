package blok.tower.target;

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
  final appFactory:AppRootFactory;
  final assetFactory:AssetContextFactory;

  public function new(container, config, appFactory, assetFactory) {
    this.container = container;
    this.config = config;
    this.appFactory = appFactory;
    this.assetFactory = assetFactory;
  }

  public function run():Cancellable {
    var document = new ClientDocument();
    var assets = assetFactory.createAssetContext(document);
    var root = hydrate(
      document.getRoot(),
      () -> appFactory.create(
        () -> {
          var nav = new Navigator({ request: new Request(Get, getLocation()) });
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
