package blok.tower.target;

import haxe.macro.Compiler;
import blok.context.Context;

@:fallback(TargetContext.instance())
class TargetContext implements Context {
  public static function instance():TargetContext {
    static var context:Null<TargetContext> = null;
    if (context == null) {
      var target:Target = if (Compiler.getDefine('blok.tower.client.ssg') != null) {
        StaticSiteGeneratedTarget;
      } else if (Compiler.getDefine('blok.tower.client') != null) {
        ServerSideRenderTarget;
      } else {
        ClientSideTarget;
      }
      context = new TargetContext(target);
    }
    return context;
  }

  final target:Target;

  public function new(target) {
    this.target = target;
  }

  public function get() {
    return target;
  }

  public function dispose() {
    // noop
  }
}
