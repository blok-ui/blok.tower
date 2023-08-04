package blok.tower.core;

import blok.tower.config.Config;
import blok.tower.asset.AssetContext;
import blok.debug.Debug;
import blok.context.Context;

@:fallback(error('No AppContext was provided'))
class AppContext implements Context {
  public final container:Container;
  public final assets:AssetContext;
  public final config:Config;

  public function new(container, assets, config) {
    this.container = container;
    this.assets = assets;
    this.config = config;
  }

  public function dispose() {
    assets.dispose();
  }
}
