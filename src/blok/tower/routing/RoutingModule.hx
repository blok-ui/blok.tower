package blok.tower.routing;

import blok.tower.core.*;

class RoutingModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    container
      .map(ViewRouteCollection)
      .toDefault(() -> new ViewRouteCollection([]))
      .share({ scope: Parent });
    container
      .map(ApiRouteCollection)
      .toDefault(() -> new ApiRouteCollection([]))
      .share({ scope: Parent });
  }
}
