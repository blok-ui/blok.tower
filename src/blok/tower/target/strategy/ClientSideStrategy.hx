package blok.tower.target.strategy;

import blok.html.client.Client;
import blok.tower.asset.*;
import blok.tower.asset.document.ClientDocument;
import blok.tower.client.HistoryController;
import blok.tower.core.*;
import blok.tower.data.HydrationId;
import blok.tower.routing.Navigator;
import kit.http.Request;

class ClientSideStrategy implements Strategy {
  final container:Container;
  final appFactory:AppRootFactory;
  final appVersion:AppVersion;
  final hydrationId:HydrationId;
  final output:Output;

  public function new(container, appVersion, appFactory, hydrationId, output) {
    this.container = container;
    this.appVersion = appVersion;
    this.appFactory = appFactory;
    this.hydrationId = hydrationId;
    this.output = output;
  }

  public function run():Cancellable {
    var document = new ClientDocument();
    var assets = new AssetContext(output, document, hydrationId, ClientSideTarget);
    var root = hydrate(
      document.getRoot(),
      () -> appFactory.create(
        () -> {
          var nav = new Navigator({ request: new Request(Get, getLocation()) });
          var link = bindNavigatorToBrowserHistory(nav);
          // @todo: how to dispose of the link?
          nav;
        }, 
        () -> new AppContext(container, appVersion, assets)
      )
    );

    return () -> root.dispose(); 
  }
}
