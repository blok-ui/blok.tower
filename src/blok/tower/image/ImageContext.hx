package blok.tower.image;

import blok.context.Context;

@:fallback(new ImageContext(new ImageConfig({})))
class ImageContext implements Context {
  public final config:ImageConfig;
  
  public function new(config) {
    this.config = config;
  }

  public function dispose() {}
}
