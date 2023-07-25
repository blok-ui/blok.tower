package blok.tower.remote;

import blok.tower.config.Config;
import kit.http.*;

using haxe.io.Path;

class StaticFileClient {
  final config:Config;
  final cache:StaticFileCache;
  final adaptor:ClientAdaptor;

  public function new(config, adaptor, cache) {
    this.config = config;
    this.adaptor = adaptor;
    this.cache = cache;
  }
  
  public function fetch<T:{}>(hash:String):Task<T> {
    var key = createCacheKey(hash);
    return cache.get(key).next(value -> switch value {
      case Some(value):
        Task.resolve(value);
      case None:
        var url = config.path.createApiUrl(hash).withExtension('json');
        var request = new Request(Get, url, [ new HeaderField(Accept, 'application/json') ]);
        adaptor.fetch(request).next(value -> {
          cache.set(key, value);
          Task.resolve(value);
        });
    });
  }
}

private function createCacheKey(key:String) {
  return 'blok.tower.static-file-client:$key';
}
