package blok.tower.routing;

import blok.core.*;
import kit.http.Request;

interface Route<T> extends Disposable {
  public function test(request:Request):Bool;
  public function match(request:Request):Maybe<T>;
}
