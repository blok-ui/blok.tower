package blok.tower.content;

import blok.tower.core.*;

class ContentModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    container.map(ContentFactory).toDefault(new ContentFactory([])).share();
    container.map(ContentRenderer).toShared(ContentRenderer);
  }
}
