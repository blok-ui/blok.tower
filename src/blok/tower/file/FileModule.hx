package blok.tower.file;

import blok.tower.core.*;

class FileModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    #if !blok.tower.client
    container
      .map(FileSystemAdaptor)
      .toDefault(new blok.tower.file.adaptor.LocalFileSystemAdaptor(Sys.getCwd()))
      .share({ scope: Parent });
    container
      .map(FileSystem)
      .toDefault(FileSystem)
      .share({ scope: Parent });
    #end
  }
}