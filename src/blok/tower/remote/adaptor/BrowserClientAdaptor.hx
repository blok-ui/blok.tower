package blok.tower.remote.adaptor;

import js.Browser;
import haxe.Json;
import kit.http.*;
import kit.http.client.BrowserClient;

class BrowserClientAdaptor implements ClientAdaptor {
  final client:BrowserClient;
  final base:Url = Browser.location.origin;

  public function new(?client:BrowserClient) {
    this.client = client ?? new BrowserClient({ credentials: INCLUDE });
  }

  public function fetch<T>(req:Request):Task<T> {
    var url = req.url.withScheme(base.scheme).withDomain(base.domain);
    return client.request(req.withUrl(url)).next(response -> {
      var data = response.body.unwrap()?.toBytes()?.toString();
      if (data == null) return new Error(NotFound, 'Empty response');
      try {
        return Task.resolve(Json.parse(data));
      } catch (e) {
        return new Error(InternalError, 'Json parse failed: ${e.message}');
      }
    });
  }
}
