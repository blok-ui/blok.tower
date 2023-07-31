package blok.tower.cli;

import blok.tower.cli.command.*;
import blok.tower.config.BlokTomlParser;
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
    container.map(BlokTomlParser).to(BlokTomlParser);
    // @todo: this should not have to be a Task<Config>.
    container.map(Task(Config)).toDefault((parser:BlokTomlParser) -> parser.load()).share({ scope: Parent });
  }

  function provideCommands(container:Container) {
    container.map(Create).to(Create);
    container.map(BuildApp).to(BuildApp);
  }
}
