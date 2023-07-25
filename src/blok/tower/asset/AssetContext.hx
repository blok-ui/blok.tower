package blok.tower.asset;

import blok.tower.config.Config;
import blok.tower.data.HydrationId;
import blok.context.Context;
import blok.tower.core.AppContext;
import blok.tower.target.Target;

@:fallback(AppContext.from(context).assets)
class AssetContext implements Context {
  public final output:Output;
  public final config:Config;
  public final document:Document;
  public final hydrationId:HydrationId;
  
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
