package blok.tower.config;

import haxe.Resource;

using haxe.Json;

class ResourceConfigFactory implements ConfigFactory {
  public function new() {}

  public function createConfig():Config {
    return Config.fromJson(Resource.getString('blok.tower.config').parse());
  }
}
