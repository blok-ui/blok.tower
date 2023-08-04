package blok.tower.asset;

import blok.context.Context;
import blok.tower.config.Config;
import blok.tower.core.AppContext;
import blok.tower.data.HydrationId;

@:fallback(AppContext.from(context).assets)
class AssetContext implements Context {
  public final output:Output;
  public final config:Config;
  public final hydrationId:HydrationId;
  public final document:Document;
  
  public function new(output, config, document, hydrationId) {
    this.output = output;
    this.config = config;
    this.document = document;
    this.hydrationId = hydrationId;
  }

  public function add(asset:Asset) {
    asset.register(this);
  }

  public function dispose() {}
}
