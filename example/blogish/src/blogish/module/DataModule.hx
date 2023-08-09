package blogish.module;

import blogish.data.*;
import blok.tower.cache.Cache;
import blok.tower.cache.TransientCache;
import blok.tower.core.*;
import blok.tower.format.*;

/**
  This module sets up all the dependencies we need for our
  backend.
**/
class DataModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    #if !blok.tower.client
    container.map(MarkdownFormat(Dynamic))
      .to(() -> new MarkdownFormat(new TomlFormat()))
      .share();
    container
      .map(Cache(Dynamic))
      .to(() -> new TransientCache(TransientCache.ONE_MINUTE))
      .share();
    container
      .map(Repository)
      .to(Repository)
      .share();
    #end
  }
}
