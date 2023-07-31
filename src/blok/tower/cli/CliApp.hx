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

  @:command final create:Create;
  @:command final build = new BuildApp();

  public function new(create) {
    this.create = create;
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
