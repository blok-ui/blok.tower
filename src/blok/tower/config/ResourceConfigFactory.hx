package blok.tower.config;

import haxe.Resource;

using haxe.Json;

class ResourceConfigFactory implements ConfigFactory {
  public function new() {}

  public function createConfig():Config {
    return Resource
      .getString('blok.tower.config')
      .parse()
      .pipe(Config.fromJson(_));
  }
}
