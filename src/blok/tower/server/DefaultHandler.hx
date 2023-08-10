package blok.tower.server;

import blok.html.Server.mount;
import blok.html.server.*;
import blok.tower.asset.document.StaticDocument;
import blok.tower.ui.internal.DefaultErrorHandler;
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
        var head:Element = document.getHead();
        var title = new Element('title', {});

        title.append(new TextNode('Error'));
        head.append(title);
        
        mount(document.getRoot(), () -> DefaultErrorHandler.node({
          error: new Error(404, 'Page not found')
        })); 
        
        document.toString();
    }));
  }
}
