package blok.tower.module;

import blok.tower.core.*;

/**
  If you're using Tower's CLI, this is the module you
  should use. It will automatically map the correct classes
  based on your configuration.
**/
class PreConfiguredTargetModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    #if (blok.tower.type == 'static')
    container.use(StaticTargetModule);
    #else
    container.use(DynamicTargetModule);
    #end
  }
}
