package blok.tower.module;

import blok.tower.target.strategy.*;
import blok.tower.config.Config;
import blok.tower.core.*;
import blok.tower.target.*;

class ServerSideRenderingModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    container.map(Config).toDefault((target:Target) -> {
      return new Config({
        output: new OutputConfig({ target: target }),
        server: new ServerConfig({}),
        path: new PathConfig({ staticPrefix: '/public' })
      });
    }).share({ scope: Parent });

    #if blok.tower.client
    container.map(blok.tower.remote.ClientAdaptor).to(() -> {
      return new blok.tower.remote.adaptor.BrowserClientAdaptor();
    }).share();
    container.map(blok.tower.remote.JsonRpcClient).to(blok.tower.remote.JsonRpcClient).share();
    container.map(Target).to(Target.ClientSideTarget).share();
    container.map(Strategy).to(ClientSideStrategy).share();
    #else
    container.use(blok.tower.server.ServerModule);
    container.map(Target).to(Target.ServerSideRenderingTarget).share();
    container.map(Visitor).to(Visitor).share({ scope: Parent });
    container.map(Generator).to(Generator).share({ scope: Parent });
    container.map(Strategy).to(ServerSideRenderingStrategy).share();
    #end
  }
}
