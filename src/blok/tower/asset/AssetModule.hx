package blok.tower.asset;

import blok.tower.asset.data.*;
import blok.tower.core.*;

class AssetModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    #if !blok.tower.client
    container.map(SourceDirectory)
      .toDefault((fs:blok.tower.file.FileSystem) -> fs.openDirectory('data'))
      .share();
    container.map(PrivateDirectory)
      .toDefault((fs:blok.tower.file.FileSystem) -> fs.openDirectory('dist/data'))
      .share();
    container.map(PublicDirectory)
      .toDefault((fs:blok.tower.file.FileSystem) -> fs.openDirectory('dist/public'))
      .share();
    #end
    container.map(Output)
      .toDefault(Output)
      .share();
  }
}
