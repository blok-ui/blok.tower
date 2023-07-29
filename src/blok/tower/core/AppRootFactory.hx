package blok.tower.core;

import blok.boundary.ErrorBoundary;
import blok.context.Provider;
import blok.suspense.SuspenseBoundary;
import blok.tower.routing.*;
import blok.tower.routing.Navigator;
import blok.tower.ui.internal.*;

class AppRootFactory {
  final root:AppRoot;
  final routes:Factory<ViewRouteCollection>;

  public function new(root, routes) {
    this.root = root;
    this.routes = routes;
  }

  public function create(
    createNavigator:()->Navigator,
    createContext:()->AppContext
  ) {
    return ErrorBoundary.node({
      fallback: (_, error) -> DefaultErrorHandler.node({ error: error }),
      child: Provider.compose([
        createNavigator,
        createContext
      ], _ -> SuspenseBoundary.node({
        fallback: () -> DefaultSuspenseHandler.node({}),
        child: root(ViewRouter.node({ routes: routes.create() }))
      }))
    });
  }
}
