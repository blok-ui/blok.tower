package blok.tower.module;

import blok.tower.core.*;
import blok.tower.target.*;
import blok.tower.target.strategy.*;

class StaticSiteGenerationModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    #if blok.tower.client
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