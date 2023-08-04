package blok.tower.module;

import blok.tower.target.strategy.*;
import blok.tower.core.*;
import blok.tower.target.*;

class ServerSideRenderingModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    #if blok.tower.client
    container.map(blok.tower.remote.ClientAdaptor).to(() -> {
      return new blok.tower.remote.adaptor.BrowserClientAdaptor();
    }).share();
    container.map(blok.tower.remote.JsonRpcClient).to(blok.tower.remote.JsonRpcClient).share();
    container.map(Target).to(Target.ClientSideTarget);
    container.map(Strategy).to(ClientSideStrategy).share();
    #else
    container.use(blok.tower.server.ServerModule);
    container.map(Target).to(Target.ServerSideRenderingTarget);
    container.map(Visitor).to(Visitor).share();
    container.map(Generator).to(Generator).share();
    container.map(Strategy).to(ServerSideRenderingStrategy).share();
    #end
  }
}
