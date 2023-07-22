package blok.tower.target.strategy;

import blok.tower.data.HydrationId;
import blok.html.client.Client;
import blok.tower.asset.*;
import blok.tower.asset.document.ClientDocument;
import blok.tower.core.*;
import js.Browser;
import kit.http.Request;

class ClientSideStrategy implements Strategy {
  final container:Container;
  final appFactory:AppRootFactory;
  final hydrationId:HydrationId;
  final output:Output;

  public function new(container, appFactory, hydrationId, output) {
    this.container = container;
    this.appFactory = appFactory;
    this.hydrationId = hydrationId;
    this.output = output;
  }

  public function run():Cancellable {
    var document = new ClientDocument();
    var request = new Request(Get, getLocation());
    var assets = new AssetContext(output, document, hydrationId, ClientSideTarget);
    var root = hydrate(
      document.getRoot(),
      () -> appFactory.create(request, () -> new AppContext(container, assets))
    );

    return () -> root.dispose(); 
  }
  
  function getLocation() {
    return Browser.location.pathname + Browser.location.hash + Browser.location.search;
  }
}
