package blok.tower.remote;

import kit.http.*;

using haxe.io.Path;

class StaticFileClient {
  final adaptor:ClientAdaptor;

  public function new(adaptor) {
    this.adaptor = adaptor;
  }
  
  public function fetch<T:{}>(hash:String):Task<T> {
    var url = Path.join([
      '/api', // @todo: make configurable
      hash
    ]).withExtension('json');
    var request = new Request(Get, url, [ new HeaderField(Accept, 'application/json') ]);
    return adaptor.fetch(request);
  }
}
