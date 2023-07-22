package blok.tower.routing;

import kit.http.StatusCode;
import haxe.Exception;

class RoutingError extends Exception {
  public final status:StatusCode;

  public function new(status, message) {
    super(message);
    this.status = status;
  }
}
