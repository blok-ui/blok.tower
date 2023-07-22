package blok.tower.target.compile;

import blok.tower.core.PluginContext;
import blok.tower.asset.*;

class ClientAppCompiler implements Asset {
  final plugins:PluginContext;

  public function new(plugins) {
    this.plugins = plugins;
  }

  public function register(context:AssetContext) {}
}
