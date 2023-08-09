package blok.tower.asset;

import blok.tower.config.Config;
import blok.tower.data.HydrationId;

class AssetContextFactory {
  final output:Output;
  final config:Config;
  final hydrationId:HydrationId;
  final bundle:AssetBundle;

  public function new(output, config, bundle, hydrationId) {
    this.output = output;
    this.config = config;
    this.hydrationId = hydrationId;
    this.bundle = bundle;
  }

  public function createAssetContext(document:Document) {
    var context = new AssetContext(output, config, document, hydrationId);
    context.add(bundle);
    return context;
  }
}
