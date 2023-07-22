package blok.tower.asset;

abstract class Document {
  public function new() {}
  
  public function getRoot():Dynamic {
    // @todo: make configurable
    return getLayer('root');
  }

  abstract public function getHead():Dynamic;
  abstract public function getBody():Dynamic;
  abstract public function getLayer(id:String):Dynamic;
  abstract public function toString():String;
  abstract public function setTitle(title:String):Void;
  abstract public function setMeta(key:String, value:String):Void;
}
