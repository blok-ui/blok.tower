package blok.tower.asset;

import blok.tower.data.HydrationId;
import blok.context.Context;
import blok.tower.core.AppContext;
import blok.tower.target.Target;

@:fallback(AppContext.from(context).assets)
class AssetContext implements Context {
  public final output:Output;
  public final document:Document;
  public final hydrationId:HydrationId;
  public final target:Target;
  
  public function new(output, document, hydrationId, target) {
    this.output = output;
    this.document = document;
    this.hydrationId = hydrationId;
    this.target = target;
  }

  public function add(asset:Asset) {
    asset.register(this);
  }

  public function dispose() {}
}
