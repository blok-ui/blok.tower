package blok.tower.server.middleware;

import blok.tower.asset.data.PublicDirectory;
import blok.tower.file.*;
import blok.tower.config.Config;
import mime.Mime;
import kit.http.*;
import kit.http.Handler;

using DateTools;
using StringTools;
using haxe.io.Path;

typedef StaticExpiry = Null<Int>;

/**
  Serves static files.

  Mostly taken from https://github.com/haxetink/tink_http_middleware/blob/master/src/tink/http/middleware/Static.hx
  with some changes for Blok.
**/
class StaticMiddleware implements Middleware {
  public final config:Config;
  public final dir:PublicDirectory;
  public final expiry:StaticExpiry;

  public function new(config, dir, expiry) {
    this.config = config;
    this.dir = dir;
    this.expiry = expiry;
  }

  public function apply(handler:Handler):Handler {
    return new StaticMiddlewareHandler(this, handler);
  }
}

class StaticMiddlewareHandler implements HandlerObject {
  final middleware:StaticMiddleware;
  final handler:Handler;

  public function new(middleware, handler) {
    this.middleware = middleware;
    this.handler = handler;
  }

  public function process(req:Request):Future<Response> {
    var path:String = req.url.path;
    var prefix = middleware.config.path.staticPrefix;

    if (req.method != Get || !path.startsWith(prefix)) {
      return handler.process(req);
    }

    var decodePath = try path.substr(prefix.length).urlDecode() catch (e) return handler.process(req);

    // decline considering anything with null bytes in this middleware
    if (decodePath.indexOf('\x00') > -1) return handler.process(req);

    return middleware.dir.getFile(decodePath)
      .next(file -> partial(req, file, Mime.lookup(decodePath)))
      .recover(_ -> handler.process(req));
  }

  function partial(
    req:Request, 
    file:File,
    contentType:String
  ):Task<Response> {
    return file.readBytes().next(source -> {
      var headers:Headers = [
        new HeaderField('Accept-Ranges', 'bytes'),
        new HeaderField('Vary', 'Accept-Encoding'),
        new HeaderField('Last-Modified', file.meta.updated.toString()),
        new HeaderField('Content-Type', contentType),
        new HeaderField('Content-Disposition', 'inline; filename="${file.meta.name}"'),
      ];
      if (middleware.expiry != null) {
        headers = headers.with(
          new HeaderField('Expires', Date.now().delta(middleware.expiry * 1000).toString()),
          new HeaderField('Cache-Control', 'max-age=${middleware.expiry}')
        );
      }

      // // @todo: We'll have to do this when we have actual streams.
      // switch req.headers.find('range') {
      //   case Some(v):
      //     switch (v:String).split('=') {
      //       case ['bytes', range]:
      //         function res(pos:Int, len:Int) {
      //           return new Response(
      //             new ResponseHeader(206, 'Partial Content', headers.concat([
      //               new HeaderField('Content-Range', 'bytes $pos-${pos + len - 1}/${file.meta.size}'),
      //               new HeaderField('Content-Length', len),
      //             ])),
      //             source.skip(pos).limit(len)
      //           );
      //         } 
                
      //         switch range.split('-') {
      //           case ['', Std.parseInt(_) => len]:
      //             return res(file.meta.size - len, len);
      //           case [Std.parseInt(_) => pos, '']:
      //             return res(pos, file.meta.size - pos);
      //           case [Std.parseInt(_) => pos, Std.parseInt(_) => end]:
      //             return res(pos, end - pos + 1);
      //           default: 
      //             // unrecognized byte-range-set (should probably return an error)
      //         }
      //       default: 
      //         // unrecognized bytes-unit (should probably return an error)
      //     }
      //   case None(_):
      // }

      return new Response(
        OK,
        headers.with(new HeaderField(ContentLength, file.meta.size)),
        source
      );
    });
  }
}
