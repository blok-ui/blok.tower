package blok.tower.remote;

using kit.Hash;

@:forward
abstract JsonRpcHash(String) to String {
  public function new(path:String, method:String, ?params:Array<Dynamic>) {
    this = [
      path,
      method,
      params?.map(Std.string)?.join('_') ?? ''
    ].join('_').hash();
  }
}
