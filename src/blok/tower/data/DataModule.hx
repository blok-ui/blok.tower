package blok.tower.data;

import blok.tower.core.*;

class DataModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    container.map(HydrationId).toDefault('__blok_tower_data').share();
    #if blok.tower.client
    container.map(Hydration).to(Hydration).share();
    #end
  }
}
