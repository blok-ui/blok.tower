package blok.tower.target;

@:using(Target.TargetTools)
enum Target {
  Cli;
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
