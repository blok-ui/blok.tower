package blok.tower.routing;

import blok.tower.core.*;

class RoutingModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    container
      .map(Factory(ViewRouteCollection))
      .toDefault(() -> () -> new ViewRouteCollection([]));
    container
      .map(ApiRouteCollection)
      .toDefault(() -> new ApiRouteCollection([]));
  }
}
