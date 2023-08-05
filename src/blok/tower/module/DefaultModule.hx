package blok.tower.module;

import blok.tower.content.ContentModule;
import blok.tower.config.ConfigModule;
import blok.tower.asset.AssetModule;
import blok.tower.core.*;
import blok.tower.data.DataModule;
import blok.tower.file.FileModule;
import blok.tower.routing.RoutingModule;

class DefaultModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    container.use(ConfigModule);
    container.use(RoutingModule);
    container.use(FileModule);
    container.use(AssetModule);
    container.use(DataModule);
    container.use(ContentModule);
  }
}
