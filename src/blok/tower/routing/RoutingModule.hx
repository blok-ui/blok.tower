package blok.tower.routing;

import blok.tower.core.*;

class RoutingModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    container
      .map(Factory(ViewRouteCollection))
      .toDefault(() -> () -> new ViewRouteCollection([]))
      .share({ scope: Container });
    container
      .map(ApiRouteCollection)
      .toDefault(() -> new ApiRouteCollection([]))
      .share({ scope: Container });
  }
}
