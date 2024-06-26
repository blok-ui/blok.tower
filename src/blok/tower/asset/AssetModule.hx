package blok.tower.asset;

import blok.tower.asset.data.*;
import blok.tower.core.*;

class AssetModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    #if !blok.tower.client
    container.map(SourceDirectory)
      .toDefault((config:blok.tower.config.Config, fs:kit.file.FileSystem) -> fs.openDirectory(config.assets.src))
      .share();
    container.map(PrivateDirectory)
      .toDefault((config:blok.tower.config.Config, fs:kit.file.FileSystem) -> fs.openDirectory(config.assets.privateDirectory))
      .share();
    container.map(PublicDirectory)
      .toDefault((config:blok.tower.config.Config, fs:kit.file.FileSystem) -> fs.openDirectory(config.assets.publicDirectory))
      .share();
    #end
    container.map(AssetContextFactory)
      .to(AssetContextFactory)
      .share();
    container.map(AssetBundle)
      .toDefault(() -> new AssetBundle([]))
      .share();
    container.map(Output)
      .toDefault(Output)
      .share();
  }
}
