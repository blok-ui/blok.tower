package blok.tower.generate;

import blok.boundary.ErrorBoundary;
import blok.context.Provider;
import blok.suspense.SuspenseBoundary;
import blok.tower.core.*;
import blok.tower.routing.*;
import blok.tower.routing.Navigator;
import blok.tower.ui.internal.*;

class Renderer {
  final routes:Factory<ViewRouteCollection>;

  public function new(routes) {
    this.routes = routes;
  }

  public function render(
    navigatorFactory:Factory<Navigator>,
    contextFactory:Factory<AppContext>
  ) {
    return ErrorBoundary.node({
      fallback: (_, error) -> DefaultErrorHandler.node({ error: error }),
      child: Provider.compose([
        navigatorFactory,
        contextFactory
      ], _ -> SuspenseBoundary.node({
        fallback: () -> DefaultSuspenseHandler.node({}),
        child: ViewRouter.node({ routes: routes.create() })
      }))
    });
  }
}
