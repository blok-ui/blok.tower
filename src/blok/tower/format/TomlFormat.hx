package blok.tower.format;

import haxe.Exception;
import toml.TomlError;

class TomlFormat<T> implements Format<T> {
  public function new() {}

  public function parse(content:String):Task<T> {
    return new Task(activate -> {
      try {
        activate(Ok(Toml.parse(content)));
      } catch (e:TomlError) {
        activate(Error(new Error(InternalError, e.toString())));
      } catch (e) {
        activate(Error(new Error(InternalError, e.toString())));
      }
    });
  }
}
