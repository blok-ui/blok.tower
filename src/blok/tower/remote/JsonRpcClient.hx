package blok.tower.remote;

import kit.http.*;

using haxe.Json;
using kit.Hash;

class JsonRpcClient {
  final adaptor:ClientAdaptor;

  public function new(adaptor) {
    this.adaptor = adaptor;
  }

  public function call(path:String, method:String, ?params:Array<Dynamic>):Task<JsonRpcResult> {
    var body = new JsonRpcRequest(method, params);
    var request = new Request(Post, path, [
      new HeaderField(ContentType, 'application/json'),
      new HeaderField(Accept, 'application/json')
    ], body.toJson().stringify());
    var task = adaptor.fetch(request).next((json:JsonRpcResult) -> switch json {
      case { error: { code: code, message: message } }: 
        new Error(switch code {
          case ParseError | InternalError: InternalError;
          case InvalidRequest: BadRequest;
          case InvalidParams: ExpectationFailed;
          case MethodNotFound: MethodNotAllowed;
          default: InternalError;
        }, message);
      default:
        json;
    });
    return task;
  }

  // @todo: batching
}
