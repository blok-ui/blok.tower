package blok.tower.core;

import blok.boundary.ErrorBoundary;
import blok.context.Provider;
import blok.suspense.SuspenseBoundary;
import blok.tower.routing.*;
import blok.tower.routing.Navigator;
import blok.ui.Placeholder;
import kit.http.Request;

class AppRootFactory {
  final root:AppRoot;
  final routes:ViewRouteCollection;

  public function new(root, routes) {
    this.root = root;
    this.routes = routes;
  }

  public function create(
    initialRequest:Request,
    createContext:()->AppContext
  ) {
    return ErrorBoundary.node({
      fallback: (component, error, recover) -> {
        // @todo: have a default error handler
        throw error;
        Placeholder.node();
      },
      child: SuspenseBoundary.node({
        fallback: () -> {
          // @todo: have a default suspense fallback
          Placeholder.node();
        },
        child: Provider.compose([
          () -> new Navigator({ request: initialRequest }),
          createContext
        ], _ -> root(ViewRouter.node({ routes: routes })))
      })
    });
  }
}
