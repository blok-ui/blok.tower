package blok.tower.cli;

import blok.tower.config.Config;

using haxe.io.Path;
using StringTools;

class BuildCommandFactory {
  final dependencies:Array<String> = [];
  final flags:Map<String, Null<String>> = [];
  final config:Config;

  public function new(config) {
    this.config = config;
  }

  public function addDependency(dependency:String) {
    if (dependencies.contains(dependency)) return;
    dependencies.push(dependency);
  }

  public function defineFlag(flag:String, ?value:String) {
    flags.set(flag, value);
  }

  public function createBuildCommand() {
    
  }
}
