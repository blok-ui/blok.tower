package blok.tower.asset;

abstract class Document {
  final options:{
    root:String
  };

  public function new(?options) {
    this.options = options ?? { root: 'root' };
  }
  
  public function getRoot():Dynamic {
    return getLayer(options.root);
  }

  abstract public function getHead():Dynamic;
  abstract public function getBody():Dynamic;
  abstract public function getLayer(id:String):Dynamic;
  abstract public function toString():String;
  abstract public function setTitle(title:String):Void;
  abstract public function setMeta(key:String, value:String):Void;
}
