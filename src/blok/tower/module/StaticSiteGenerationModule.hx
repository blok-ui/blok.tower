package blok.tower.module;

// import blok.tower.config.Config;
import blok.tower.core.*;
import blok.tower.target.*;
import blok.tower.target.strategy.*;

class StaticSiteGenerationModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    // container.map(Config).toDefault((target:Target) -> {
    //   return new Config({
    //     appName: 'app',
    //     #if !blok.tower.client
    //     output: new OutputConfig({ target: target }),
    //     #end
    //     server: new ServerConfig({}),
    //     path: new PathConfig({})
    //   });
    // }).share({ scope: Parent });

    #if blok.tower.client
    container.map(blok.tower.remote.ClientAdaptor).to(() -> {
      return new blok.tower.remote.adaptor.BrowserClientAdaptor();
    }).share({ scope: Parent });
    container.map(blok.tower.remote.StaticFileCache).toDefault(() -> {
      return new blok.tower.cache.TransientCache(blok.tower.cache.TransientCache.ONE_MINUTE);
    }).share({ scope: Parent });
    container.map(blok.tower.remote.StaticFileClient).to(blok.tower.remote.StaticFileClient).share({ scope: Parent });
    container.map(Target).to(Target.ClientSideTarget);
    container.map(Strategy).to(ClientSideStrategy).share({ scope: Parent });
    #else
    container.map(Target).to(Target.StaticSiteGeneratedTarget);
    container.map(Visitor).to(Visitor).share({ scope: Parent });
    container.map(Generator).to(Generator).share({ scope: Parent });
    container.map(Strategy).to(StaticSiteGenerationStrategy).share({ scope: Parent });
    #end
  }
}
