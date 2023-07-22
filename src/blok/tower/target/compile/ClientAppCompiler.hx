package blok.tower.target.compile;

import blok.tower.core.*;
import blok.tower.asset.*;

class ClientAppCompiler implements Asset {
  final version:AppVersion;

  public function new(version) {
    this.version = version;
  }

  public function register(context:AssetContext) {}
}
