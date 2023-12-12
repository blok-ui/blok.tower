package blok.tower.generate;

import blok.tower.core.*;

class GeneratorModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    container.map(Renderer).toDefault(Renderer).share();
    // @todo: This is a hacky way to force a dependency on Target.
    // We should look into some kind of `container.require(...)`
    // thing.
    container.map(Factory(Target)).to((target:Target) -> () -> target).share();
  }
}