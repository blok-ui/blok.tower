package blok.tower.config;

@:using(AppType.AppTypeTools)
enum abstract AppType(Int) {
  final StaticApp;
  final DynamicApp;
}

class AppTypeTools {
  public static function toString(type:AppType) {
    return switch type {
      case StaticApp: 'static';
      case DynamicApp: 'dynamic';
    }
  }

  public static function shouldOutputHtml(type:AppType) {
    return type == StaticApp;
  }
}
