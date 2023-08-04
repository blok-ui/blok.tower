package blok.tower.cli;

import blok.tower.config.TowerTomlConfigFactory;
import blok.tower.config.ConfigFactory;
import blok.tower.cli.command.*;
import blok.tower.config.Config;
import blok.tower.core.*;
import blok.tower.file.*;
import blok.tower.file.adaptor.LocalFileSystemAdaptor;

class CliAppModule implements Module {
  public function new() {}

  public function provide(container:Container) {
    provideCoreDependencies(container);
    provideCommands(container);

    container.map(CliApp).to(CliApp).share();
  }

  function provideCoreDependencies(container:Container) {
    container.map(FileSystemAdaptor).to(() -> new LocalFileSystemAdaptor(Sys.getCwd())).share();
    container.map(FileSystem).to(FileSystem).share();
    container.map(ConfigFactory).to(TowerTomlConfigFactory);
    container.map(Config).toDefault((factory:ConfigFactory) -> factory.createConfig()).share();
  }

  function provideCommands(container:Container) {
    container.map(Create).to(Create);
    container.map(Build).to(Build);
  }
}
