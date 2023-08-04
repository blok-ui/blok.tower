package blok.tower.core;

import blok.tower.core.logger.*;

class CoreModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    container.map(Container).to(() -> container).share();
    provideAppDependencies(container);
    provideLogger(container);
  }
  
  function provideAppDependencies(container:Container) {
    container.map(AppRootFactory).toDefault(AppRootFactory).share();
    container.map(AppRoot).toDefault(() -> (router) -> router).share();
  }

  function provideLogger(container:Container) {
    #if blok.tower.client
    container.map(Logger).to(ClientLogger).share();
    #else
    container.map(kit.cli.Output).to(() -> new kit.cli.output.SysOutput()).share();
    container.map(Logger).to(ServerLogger).share();
    #end
  }
}
