package blok.tower.config;

import blok.tower.asset.*;

using kit.Hash;
using haxe.Json;

class ConfigAsset implements Asset {
  public static final id:String = '__blok_tower_config';

  public function new() {}

  public function register(context:AssetContext) {
    context.add(new JsonAsset({
      id: id,
      content: context.config.toJson().stringify()
    }));
  }
}
