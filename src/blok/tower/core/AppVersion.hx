package blok.tower.core;

import haxe.macro.Compiler;

/**
  The current version of your app. This is used internally
  to help ensure generated CSS and JS files are unique.

  You can set the version with `-D blok.tower.app.version=1.2.3`
  in your build hxml, or you can map it directly in a Module.
**/
@:forward
@:forward.new
abstract AppVersion(SemVer) from SemVer to SemVer {
  public static function fromCompiler():AppVersion {
    var version:Null<String> = Compiler.getDefine('blok.tower.app.version');
    if (version == null) return new SemVer(0, 0, 0);
    return SemVer.parse(version);
  }
}
