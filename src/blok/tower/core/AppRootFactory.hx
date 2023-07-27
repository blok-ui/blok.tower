package blok.tower.core;

import blok.boundary.ErrorBoundary;
import blok.context.Provider;
import blok.suspense.SuspenseBoundary;
import blok.tower.routing.*;
import blok.tower.routing.Navigator;
import blok.ui.*;
import blok.html.Html;

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
      fallback: (component, error, recover) -> {
        // @todo: have a default error fallback
        Html.div({}, error.toString());
      },
      child: Provider.compose([
        createNavigator,
        createContext
      ], _ -> SuspenseBoundary.node({
        fallback: () -> {
          // @todo: have a default suspense fallback
          Placeholder.node();
        },
        child: root(ViewRouter.node({ routes: routes.create() }))
      }))
    });
  }
}