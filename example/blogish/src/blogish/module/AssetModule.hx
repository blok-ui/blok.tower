package blogish.module;

import haxe.macro.Compiler;
import blok.tower.core.*;
import blok.tower.asset.*;

/**
  This Module provides an example of how to add assets to
  the AssetBundle. This will ensure that the given assets
  are available on *every* route.

  For per-layout or per-route assets, use `AssetContext.from(...).add(...)`
  inside the desired route or layout's `render` method.
**/
class AssetModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    container.getMapping(AssetBundle).extend(bundle -> {
      bundle.add(new CssAsset(Compiler.getDefine('breeze.output'), Generated));
      return bundle;
    });
  }
}
