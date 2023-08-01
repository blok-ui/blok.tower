package blok.tower.config;

import blok.tower.core.*;

class ConfigModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    #if blok.tower.client
    container.map(ConfigFactory).to(HydratingConfigFactory);
    #else
    container.map(ConfigFactory).to(TowerTomlConfigFactory);
    #end
    container.map(Config).to((factory:ConfigFactory) -> factory.createConfig()).share();
  }
}
