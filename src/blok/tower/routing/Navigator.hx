package blok.tower.routing;

import blok.context.Context;
import blok.data.Record;
import blok.debug.Debug;
import kit.http.Request;

@:fallback(error('No Navigator found'))
class Navigator extends Record implements Context {
  @:signal public final request:Request;

  @:action
  public function go(url:String) {
    if (url == request.peek().url) return;
    request.set(new Request(Get, url));
  }
}
