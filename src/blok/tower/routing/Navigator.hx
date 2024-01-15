package blok.tower.routing;

import blok.context.Context;
import blok.data.Model;
import blok.debug.Debug;
import kit.http.Request;

@:fallback(error('No Navigator found'))
class Navigator extends Model implements Context {
  @:signal public final request:NavigatorRequest;

  @:action
  public function go(url:String, isPopState = false) {
    if (url == request.peek().request.url) return;
    request.set({
      request: new Request(Get, url),
      isPopState: isPopState
    });
  }
}

typedef NavigatorRequest = {
  public final request:Request;
  public final isPopState:Bool;
} 
