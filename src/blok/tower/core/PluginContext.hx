package blok.tower.core;

import blok.tower.asset.AssetContext;

class PluginContext {
  public final onAssetsProcessing = new Event<AssetContext>();
  public final onClientAppCompiling = new Event();

  public function new() {}

  public function add(plugin:Plugin) {
    plugin.register(this);
  }
}
