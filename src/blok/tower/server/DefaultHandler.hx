package blok.tower.server;

import blok.html.Html;
import blok.html.Server.mount;
import blok.tower.asset.document.StaticDocument;
import blok.tower.ui.Head;
import blok.tower.ui.internal.DefaultErrorHandler;
import blok.ui.Fragment;
import haxe.Json;
import kit.http.*;
import kit.http.Handler;

class DefaultHandler implements HandlerObject {
  public function new() {}

  public function process(request:Request):kit.Future<Response> {
    var contentType = request.headers
      .find(Accept)
      .map(type -> type.value)
      .or('text/html');

    return Future.immediate(new Response(NotFound, [
      new HeaderField(ContentType, contentType)
    ], switch contentType {
      case 'application/json': 
        Json.stringify({
          error: 'Not found'
        });
      default:
        var document = new StaticDocument();
        
        mount(document.getRoot(), () -> Fragment.node(
          Head.node({
            children: [
              Html.title({}, 'Error')
            ]
          }),
          DefaultErrorHandler.node({
            error: new Error(404, 'Page not found')
          })
        )); 
        
        document.toString();
    }));
  }
}
