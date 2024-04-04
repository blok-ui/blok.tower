package blok.tower.cli;

import blok.tower.cli.command.*;
import blok.tower.config.Config;
import blok.tower.config.ConfigFactory;
import blok.tower.config.TowerTomlConfigFactory;
import blok.tower.core.*;
import kit.file.*;
import kit.file.adaptor.SysAdaptor;

class CliAppModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    provideCoreDependencies(container);
    provideCommands(container);

    container.map(CliApp).to(CliApp).share();
  }

  function provideCoreDependencies(container:Container) {
    container.map(Adaptor).to(() -> new SysAdaptor(Sys.getCwd())).share();
    container.map(FileSystem).to(FileSystem).share();
    container.map(ConfigFactory).to(TowerTomlConfigFactory);
    container.map(Config).toDefault((factory:ConfigFactory) -> factory.createConfig()).share();
  }

  function provideCommands(container:Container) {
    container.map(Create).to(Create);
    container.map(Build).to(Build);
  }
}
