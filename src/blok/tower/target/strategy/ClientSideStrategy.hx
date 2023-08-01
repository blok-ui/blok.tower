package blok.tower.target.strategy;

import blok.html.client.Client;
import blok.tower.asset.*;
import blok.tower.asset.document.ClientDocument;
import blok.tower.client.HistoryTools;
import blok.tower.config.Config;
import blok.tower.core.*;
import blok.tower.data.HydrationId;
import blok.tower.routing.Navigator;
import kit.http.Request;

class ClientSideStrategy implements Strategy {
  final container:Container;
  final config:Config;
  final appFactory:AppRootFactory;
  final appVersion:AppVersion;
  final hydrationId:HydrationId;
  final output:Output;

  public function new(container, config, appVersion, appFactory, hydrationId, output) {
    this.container = container;
    this.config = config;
    this.appVersion = appVersion;
    this.appFactory = appFactory;
    this.hydrationId = hydrationId;
    this.output = output;
  }

  public function run():Cancellable {
    var document = new ClientDocument();
    var assets = new AssetContext(output, config, document, ClientSideTarget, hydrationId);
    var root = hydrate(
      document.getRoot(),
      () -> appFactory.create(
        () -> {
          var nav = new Navigator({ request: new Request(Get, getLocation()) });
          var link = bindNavigatorToBrowserHistory(nav);
          nav.addDisposable(() -> link.cancel());
          nav;
        }, 
        () -> new AppContext(container, appVersion, assets)
      )
    );

    return () -> root.dispose(); 
  }
}
