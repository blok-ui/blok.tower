package blok.tower.routing;

import kit.http.Request;

interface Route<T> {
  public function test(request:Request):Bool;
  public function match(request:Request):Maybe<T>;
}
