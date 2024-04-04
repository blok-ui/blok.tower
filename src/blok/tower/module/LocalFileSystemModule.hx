package blok.tower.module;

import blok.tower.core.*;

class LocalFileSystemModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    #if !blok.tower.client
    container
      .map(kit.file.Adaptor)
      .toDefault(new kit.file.adaptor.SysAdaptor(Sys.getCwd()))
      .share();
    container
      .map(kit.file.FileSystem)
      .toDefault(kit.file.FileSystem)
      .share();
    #end
  }
}
