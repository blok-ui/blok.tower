package blok.tower.config;

import blok.tower.core.*;

class ConfigModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    #if blok.tower.pre_configured
    container.map(ConfigFactory).to(ResourceConfigFactory);
    #elseif blok.tower.client
    container.map(ConfigFactory).to(HydratingConfigFactory);
    #else
    container.map(ConfigFactory)
      .toDefault((assets:blok.tower.asset.AssetBundle) -> {
        var config = new TowerTomlConfigFactory();
        assets.add(new ConfigAsset());
        return config;
      });
    #end
    container.map(Config).to((factory:ConfigFactory) -> factory.createConfig()).share();
  }
}
