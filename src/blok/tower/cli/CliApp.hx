package blok.tower.cli;

import blok.tower.core.*;
import blok.tower.cli.command.*;

using kit.Cli;

class CliApp implements Command {
  public static function run() {
    var container = Container.build(new CliAppModule());
    var app = container.get(CliApp);
    Cli.fromSys().execute(app);
  }

  /**
    Quickly create various classes for Tower.
  **/
  @:command final create:Create;

  /**
    Build your app and set up dependencies.
  **/
  @:command final build:Build;

  public function new(create, build) {
    this.create = create;
    this.build = build;
  }

  /**
    Tools for building Blok Tower apps.
  **/
  @:defaultCommand
  function help():Task<Int> {
    output.write(getDocs());
    return 0;
  }
}
