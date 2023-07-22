package blok.tower.core;

import blok.tower.core.logger.*;

class CoreModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    container.map(Container).to(() -> container).share({ scope: Parent });
    container.map(AppRootFactory).toDefault(AppRootFactory).share({ scope: Parent });
    container.map(AppRoot).toDefault(() -> (router) -> router).share({ scope: Parent });
    #if blok.tower.client
    container.map(Logger).to(ClientLogger).share({ scope: Parent });
    #else
    container.map(cmdr.Output).to(() -> new cmdr.output.SysOutput()).share({ scope: Parent });
    container.map(Logger).to(ServerLogger).share({ scope: Parent });
    #end
  }
}
