package blok.tower.image;

import blok.context.Context;

// @todo: Use this class as a central hub for loading images better
// on the client side?
@:fallback(new ImageContext(new ImageConfig({})))
class ImageContext implements Context {
  public final config:ImageConfig;
  
  public function new(config) {
    this.config = config;
  }

  public function dispose() {}
}
