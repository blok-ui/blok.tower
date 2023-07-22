package blok.tower.core;

import blok.tower.asset.AssetContext;
import blok.debug.Debug;
import blok.context.Context;

@:fallback(error('No AppContext was provided'))
class AppContext implements Context {
  public final container:Container;
  public final version:AppVersion;
  public final assets:AssetContext;

  public function new(container, version, assets) {
    this.container = container;
    this.version = version;
    this.assets = assets;
  }

  public function dispose() {
    assets.dispose();
  }
}
