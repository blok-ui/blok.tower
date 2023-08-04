package blok.tower.target;

// @todo: Probably drop this in favor of `config.type`?
@:using(Target.TargetTools)
enum Target {
  ServerSideRenderingTarget;
  StaticSiteGeneratedTarget;
  ClientSideTarget;  
}

class TargetTools {
  static public function shouldOutputHtml(target:Target) {
    return switch target {
      case StaticSiteGeneratedTarget: true;
      default: false;
    }
  }
}
