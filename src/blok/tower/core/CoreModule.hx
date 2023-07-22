package blok.tower.core;

import blok.tower.core.logger.*;

class CoreModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    container.map(Container).to(() -> container).share({ scope: Parent });
    provideAppDependencies(container);
    provideLogger(container);
  }
  
  function provideAppDependencies(container:Container) {
    container.map(AppRootFactory).toDefault(AppRootFactory).share({ scope: Parent });
    container.map(AppRoot).toDefault(() -> (router) -> router).share({ scope: Parent });
    container.map(AppVersion).toDefault(() -> AppVersion.fromCompiler()).share({ scope: Parent });
  }

  function provideLogger(container:Container) {
    #if blok.tower.client
    container.map(Logger).to(ClientLogger).share({ scope: Parent });
    #else
    container.map(cmdr.Output).to(() -> new cmdr.output.SysOutput()).share({ scope: Parent });
    container.map(Logger).to(ServerLogger).share({ scope: Parent });
    #end
  }
}
