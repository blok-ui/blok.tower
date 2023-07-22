package blok.tower.format;

import haxe.Json;

class JsonFormat<T> implements Format<T> {
  public function new() {}
  
  public function parse(content:String):Task<T> {
    return Task.resolve(Json.parse(content));
  }
}
