package blok.tower.server;

import blok.tower.server.middleware.StaticMiddleware.StaticExpiry;
import blok.tower.config.Config;
import blok.tower.core.*;
import blok.tower.server.middleware.*;
import kit.http.*;
import kit.http.server.NodeServer;

class ServerModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    #if !forest.client
    provideConnection(container);
    providerServerAndMiddleware(container);
    #end
  }

  public function provideConnection(container:Container) {
    // @todo: This is temporary -- connection stuff needs configuration.
    // Also we should change the kind of connection based on platform.
    container.map(Server).to((config:Config) -> {
      return new NodeServer(config.server.port);
    }).share({ scope: Parent });
  }

  public function providerServerAndMiddleware(container:Container) {
    container.map(StaticExpiry).toDefault(() -> null).share();
    container.map(StaticMiddleware).to(StaticMiddleware);
    container.map(ApiRouterMiddleware).to(ApiRouterMiddleware);
    container.map(ViewRouterMiddleware).to(ViewRouterMiddleware);
    container.map(MiddlewareCollection).to((staticMw:StaticMiddleware, apiMw:ApiRouterMiddleware, viewMw:ViewRouterMiddleware) -> {
      return new MiddlewareCollection([ staticMw, apiMw, viewMw ]);
    }).share();
    container.map(Handler).to(DefaultHandler).share();
    container.map(ServerRunner).to(ServerRunner).share();
  }
}
