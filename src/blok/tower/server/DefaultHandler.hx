package blok.tower.server;

import kit.http.*;
import kit.http.Handler;

class DefaultHandler implements HandlerObject {
  public function new() {}

  public function process(request:Request):kit.Future<Response> {
    // @todo: change response based on what the request accepts.
    return Future.immediate(new Response(NotFound, [], 'Page not found'));
  }
}
