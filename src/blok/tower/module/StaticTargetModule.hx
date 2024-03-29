package blok.tower.module;

import blok.tower.core.*;
import blok.tower.generate.*;

/**
  Includes the dependencies needed to generate an app that
  uses pre-generated static files on the backend.
**/
class StaticTargetModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    #if blok.tower.client
    container.map(blok.tower.remote.ClientAdaptor).to(() -> {
      return new blok.tower.remote.adaptor.BrowserClientAdaptor();
    }).share();
    container.map(blok.tower.remote.StaticFileCache).toDefault(() -> {
      return new blok.tower.cache.TransientCache(blok.tower.cache.TransientCache.ONE_MINUTE);
    }).share();
    container.map(blok.tower.remote.StaticFileClient).to(blok.tower.remote.StaticFileClient).share();
    container.map(Target).to(ClientTarget).share();
    #else
    // @todo: Adding the client app this way feels a bit fragile.
    container.getMapping(blok.tower.asset.AssetBundle).extend(bundle -> {
      var compiler = container.instantiate(blok.tower.generate.ClientAppAsset);
      bundle.add(compiler);
      return bundle;
    });
    container.map(Visitor).to(Visitor).share();
    container.map(Generator).to(Generator).share();
    container.map(Target).to(StaticTarget).share();
    #end
  }
}
