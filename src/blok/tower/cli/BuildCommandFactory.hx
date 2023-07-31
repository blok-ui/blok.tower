package blok.tower.cli;

import blok.tower.core.AppVersion;
import blok.tower.config.Config;

using haxe.io.Path;
using StringTools;

class BuildCommandFactory {
  final dependencies:Array<String> = [];
  final flags:Map<String, Null<String>> = [];
  final config:Config;
  final version:AppVersion;

  public function new(config, version) {
    this.config = config;
    this.version = version;
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
