package blok.tower.routing;

import haxe.macro.Context;
import haxe.macro.Expr;
import blok.macro.ClassBuilder;

using Lambda;
using blok.macro.MacroTools;
using kit.Hash;
using blok.tower.routing.macro.RouteBuilder;
using haxe.macro.Tools;

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, [
      TInst(_.get() => {kind: KExpr(macro $v{(url:String)})}, _)
    ]):
      buildJsonRpcRoute(url.normalizeUrl());
    default:
      throw 'assert';
  }  
}

function build(url:String) {
  if (Context.defined('blok.tower.client.ssg')) return buildStaticClient(url);
  if (Context.defined('blok.tower.client')) return buildClient(url);

  var builder = ClassBuilder.fromContext();
  var responseCases:Array<Case> = [];
  
  for (field in builder.getFields()) switch field.kind {
    case FFun(f) if (isRpcMethod(field)):
      if (f.ret == null) {
        Context.error('Return types cannot be inferred here', field.pos);
      }

      switch f.ret.toType().follow().toComplexType() {
        case macro:kit.Task<$t, $_>: 
        default: Context.error('RPC methods must return a kit.Task', field.pos);
      }

      var name = field.name;
      var args = f.args.map(f -> macro $i{f.name});
      var params = args.length > 0 ? macro [ $a{args} ] : macro null;
      var call = args.length > 0 ? macro this.$name($a{args}) : macro this.$name();
      
      responseCases.push({
        values: [ macro { method: $v{name}, params: $params } ],
        expr: macro ${call}.next(value -> createJsonRpcResult(__request.id, value))
      });
    default:
  }

  var switchExpr:Expr = {
    expr: ESwitch(
      macro __request,
      responseCases,
      macro kit.Task.resolve(createJsonRpcErrorResult(__request.id, MethodNotFound, 'No method exists with the name ' + __request.method))
    ),
    pos: (macro null).pos
  };

  builder.add(macro class {
    @:noCompletion static final __url = $v{url};

    public function test(request:kit.http.Request):Bool {
      if (request.method != Post) return false;
      return request.url == __url;
    }

    public function match(request:kit.http.Request):kit.Maybe<kit.Future<kit.http.Response>> {
      if (!test(request)) return None;
  
      var __request = request.body
        .map(body -> haxe.Json.parse(body.toBytes().toString()))
        .map(body -> new blok.tower.remote.JsonRpcRequest(body.method, body.params, body.id))
        .unwrap();

      if (__request == null) {
        var response = new kit.http.Response(InternalServerError, new kit.http.Headers(
          new kit.http.HeaderField(ContentType, 'application/json')
        ), haxe.io.Bytes.ofString(haxe.Json.stringify(createParseErrorResponse())));
        return Some(kit.Future.immediate(response));
      }

      var result:kit.Task<blok.tower.remote.JsonRpcResult> = $switchExpr;
      var response = result
        .next(res -> new kit.http.Response(OK, new kit.http.Headers(
          new kit.http.HeaderField(ContentType, 'application/json')
        ), haxe.io.Bytes.ofString(haxe.Json.stringify(res.toJson()))))
        .recover(error -> {
          var res = createJsonRpcErrorResult(null, InternalError, error.message);
          return kit.Future.immediate(new kit.http.Response(InternalServerError, new kit.http.Headers(
            new kit.http.HeaderField(ContentType, 'application/json')
          ), haxe.io.Bytes.ofString(haxe.Json.stringify(res.toJson()))));
        });
      return Some(response);
    }

    @:noCompletion
    inline function createJsonRpcResult<T:blok.tower.data.JsonAware>(
      id:Null<haxe.extern.EitherType<Int, String>>,
      value:T
    ):blok.tower.remote.JsonRpcResult {
      return {
        jsonrpc: '2.0',
        id: id,
        result: value.toJson()
      };
    }

    @:noCompletion
    inline function createJsonRpcErrorResult(
      id:Null<haxe.extern.EitherType<Int, String>>,
      code:blok.tower.remote.JsonRpcResult.JsonRpcResultErrorCode,
      message:String
    ):blok.tower.remote.JsonRpcResult {
      return {
        jsonrpc: '2.0',
        id: id,
        error: {
          code: code,
          message: message
        }
      };
    }
  
    @:noCompletion
    inline function createParseErrorResponse() {
      return createJsonRpcErrorResult(
        null,
        ParseError,
        'No request payload was provided or it was not parsable.'
      );
    }
  });

  return builder.export();
}

// @todo: Come up with something better here.
private function buildStaticClient(url:String) {
  var serverFields = Context.getBuildFields();
  var builder = new ClassBuilder([]);
  
  for (field in serverFields) switch field.kind {
    case FFun(f) if (isRpcMethod(field)):
      var name = field.name;
      var args = f.args;
      
      builder.addField({
        name: name,
        pos: field.pos,
        access: field.access,
        meta: field.meta,
        kind: FFun({
          args: args,
          ret: f.ret,
          expr: macro throw 'Not available on static sites'
        })
      });
    default:
  }

  builder.add(macro class {
    public function new() {}

    public function test(request:kit.http.Request):Bool {
      return false;
    }

    public function match(request:kit.http.Request):kit.Maybe<kit.Future<kit.http.Response>> {
      return None;
    }
  });

  return builder.export();
}

private function buildClient(url:String) {
  var serverFields = Context.getBuildFields();
  var builder = new ClassBuilder([]);

  builder.add(macro class {
    @:noCompletion static final __url = $v{url};
    
    final client:blok.tower.remote.JsonRpcClient;

    public function new(client) {
      this.client = client;
    }

    public function test(request:kit.http.Request):Bool {
      return false;
    }

    public function match(request:kit.http.Request):kit.Maybe<kit.Future<kit.http.Response>> {
      return None;
    }
  });
  
  for (field in serverFields) switch field.kind {
    case FFun(f) if (isRpcMethod(field)):
      var name = field.name;
      var args = f.args;
      var callArgs = args.length == 0 
        ? macro null 
        : macro [ $a{args.map(a -> macro $i{a.name})} ];
      var path = switch f.ret.toType().follow().toComplexType() {
        case macro:kit.Task<$t, $_>: switch t {
          case TPath(p): p.pack.concat([ p.name, p.sub ]).filter(n -> n != null);
          default: Context.error('Invalid return type', field.pos);
        }
        default: Context.error('Invalid return type', field.pos);
      }
      builder.addField({
        name: name,
        pos: field.pos,
        access: field.access,
        meta: field.meta,
        kind: FFun({
          args: args,
          ret: f.ret,
          expr: macro return client
            .call(__url, $v{name}, $callArgs)
            .next(res -> $p{path}.fromJson(res.result))
        })
      });
    default:
  }
  
  return builder.export();
}

private function buildJsonRpcRoute(url:String) {
  var suffix = url.hash();
  var name = 'JsonRpcRoute_${suffix}';
  var path:TypePath = { 
    pack: [ 'blok', 'tower', 'routing' ], 
    name: name, 
    params: [] 
  };

  if (path.typePathExists()) return TPath(path);

  Context.defineType({
    pack: path.pack,
    name: path.name,
    meta: [
      {
        name: ':autoBuild',
        params: [ macro blok.tower.routing.JsonRpcRouteBuilder.build($v{url}) ],
        pos: (macro null).pos
      }
    ],
    kind: TDClass(null, [
      {
        pack: [ 'blok', 'tower', 'routing' ],
        name: 'ApiRoute'
      }
    ], true),
    fields: [],
    pos: (macro null).pos
  });

  return TPath(path); 
}

private function isRpcMethod(field:Field) {
  return field.name != 'new' 
    && field.access.contains(APublic) 
    && !field.access.contains(AStatic)
    && !field.meta.exists(entry -> entry.name == ':skip');
}
