package blok.tower.module;

import blok.tower.core.*;
import blok.tower.generate.*;

/**
  Includes the dependencies needed to generate an app that
  uses a dynamic server that generates HTML and JSON responses 
  per request.
**/
class DynamicTargetModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    #if blok.tower.client
    container.map(blok.tower.remote.ClientAdaptor).to(() -> {
      return new blok.tower.remote.adaptor.BrowserClientAdaptor();
    }).share();
    container.map(blok.tower.remote.JsonRpcClient).to(blok.tower.remote.JsonRpcClient).share();
    container.map(Target).to(ClientTarget).share();
    #else
    // @todo: Adding the client app this way feels a bit fragile.
    container.getMapping(blok.tower.asset.AssetBundle).extend(bundle -> {
      var compiler = container.instantiate(blok.tower.generate.ClientAppAsset);
      bundle.add(compiler);
      return bundle;
    });
    container.use(blok.tower.server.ServerModule);
    container.map(Visitor).to(Visitor).share();
    container.map(Generator).to(Generator).share();
    container.map(Target).to(DynamicTarget).share();
    #end
  }
}
