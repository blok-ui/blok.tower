package blok.tower.remote;

import haxe.extern.EitherType;

enum abstract JsonRpcResultErrorCode(Int) {
  final ParseError = -32700;
  final InvalidRequest = -32600;
  final MethodNotFound = -32601;
  final InvalidParams = -32602;
  final InternalError = -32603;
  // -32000 to -32099 are for other error codes.
}

typedef JsonRpcResultError = {
  public final code:JsonRpcResultErrorCode;
  public final message:String;
  public final ?data:{};
} 

typedef JsonRpcResultObject = {
  public final jsonrpc:String;
  public final id:Null<EitherType<String, Int>>;
  public final ?result:{};
  public final ?error:JsonRpcResultError;
}

@:forward(jsonrpc, id, result, error)
abstract JsonRpcResult(JsonRpcResultObject) from JsonRpcResultObject {
  public inline function new(object) {
    this = object;
  }

  public function toJson():{} {
    return {
      jsonrpc: this.jsonrpc,
      id: this.id,
      result: this.result,
      error: this.error
    };
  }
}
