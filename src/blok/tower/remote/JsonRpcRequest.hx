package blok.tower.remote;

import haxe.extern.EitherType;

typedef JsonRpcRequestObject = {
  public final jsonrpc:String;
  public final method:String;
  public final ?id:EitherType<Int, String>;
  public final ?params:Array<Dynamic>; // @todo: make more flexible?
}

@:forward(jsonrpc, id, method, params)
abstract JsonRpcRequest(JsonRpcRequestObject) {
  public function new(method:String, ?params, ?id):JsonRpcRequest {
    this = {
      jsonrpc: '2.0',
      id: id ?? Math.ceil(Math.random() * 100), // @todo
      method: method,
      params: params
    };
  }

  public function toJson() {
    return {
      jsonrpc: this.jsonrpc,
      id: this.id,
      method: this.method,
      params: this.params
    }
  }
}
