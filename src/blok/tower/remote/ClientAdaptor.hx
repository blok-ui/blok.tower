package blok.tower.remote;

import kit.http.Request;

interface ClientAdaptor {
  public function fetch<T>(request:Request):Task<T>;
}
