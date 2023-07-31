package blok.tower.cli.command;

using kit.Cli;

class BuildApp implements Command {
  public function new() {}

  @:defaultCommand
  function build(?path:String):Task<Int> {
    return 0;
  }
}
