package blogish.data;

import blok.tower.cache.Cache;
import blok.tower.cache.TransientCache;
import blok.tower.core.*;
import blok.tower.format.*;

class DataModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    #if !blok.tower.client
    container.map(MarkdownFormat(Dynamic))
      .to(() -> new MarkdownFormat(new TomlFormat()))
      .share({ scope: Parent });
    container
      .map(Cache(Dynamic))
      .to(() -> new TransientCache(TransientCache.ONE_MINUTE))
      .share({ scope: Parent });
    container
      .map(Repository)
      .to(Repository)
      .share({ scope: Parent });
    #end
  }
}
