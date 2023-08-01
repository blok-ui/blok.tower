package blok.tower.config;

import blok.tower.data.Hydration;

class HydratingConfigFactory implements ConfigFactory {
  final hydration:Hydration;

  public function new(hydration) {
    this.hydration = hydration;
  }

  public function createConfig():Config {
    return hydration
      .extract(ConfigAsset.id)
      .map(Config.fromJson)
      .orThrow('No config hydration found');
  }
}
