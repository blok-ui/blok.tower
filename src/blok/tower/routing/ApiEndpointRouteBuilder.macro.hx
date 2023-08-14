package blok.tower.routing;

import haxe.macro.Context;
import haxe.macro.Expr;
import blok.macro.ClassBuilder;

using blok.tower.routing.macro.RouteBuilder;
using blok.tower.routing.internal.RouteParser;
using haxe.macro.Tools;
using kit.Hash;
using blok.macro.MacroTools;

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, [ 
      TInst(_.get() => {kind: KExpr(macro $v{(method:String)})}, _),
      TInst(_.get() => {kind: KExpr(macro $v{(url:String)})}, _)
    ]):
      buildApiEndpointRoute(method.toUpperCase(), url.normalizeUrl());
    default:
      throw 'assert';
  }
}

function build(method:String, url:String) {
  // if (isClient()) return switch getAppType() {
  //   case StaticApp: buildStaticClient(url);
  //   default: buildClient(url);
  // }

  var builder = ClassBuilder.fromContext();
  var route = url.processRoute();
  var routeParamsType = route.paramsType;
  
  builder.add(macro class {
    static final method:kit.http.Method = kit.http.Method.parse($v{method}).or(() -> kit.http.Method.Get);
    static final matcher = ${route.matcher};
  
    public function test(request:kit.http.Request):Bool {
      if (request.method != method) return false;
      return matcher.match(request.url);
    }

    public function match(request:kit.http.Request):kit.Maybe<kit.Future<kit.http.Request>> {
      if (request.method != method) return false;
      if (matcher.match(url)) {
        return Some(handle(${route.paramsBuilder}));
      }
      return None;
    }

    public function dispose() {}
  });

  return builder.export();
}

function buildApiEndpointRoute(method:String, url:String) {
  if (!validateHttpMethod(method)) {
    Context.error('Invalid Http method: ${method}', Context.currentPos());
  }

  var pos = Context.getLocalClass().get().pos;
  var suffix = method + '_' + url.hash();
  var pack = [ 'blok', 'tower', 'routing' ];
  var name = 'ApiEndpointRoute_${suffix}';
  var path:TypePath = { pack: pack, name: name, params: [] };

  if (path.typePathExists()) return TPath(path);

  var builder = new ClassBuilder([]);
  var route = url.processRoute();
  var routeParamsType = route.paramsType;

  builder.add(macro class {
    public function handle(params:$routeParamsType):kit.Future<kit.http.Response>;
  });
  
  Context.defineType({
    pack: pack,
    name: name,
    pos: pos,
    meta: [
      { 
        name: ':autoBuild',
        params: [ macro blok.tower.routing.ApiEndpointRouteBuilder.build($v{method}, $v{url}) ],
        pos: pos
      }
    ],
    kind: TDClass(null, [
      {
        pack: pack,
        name: 'ApiRoute'
      }
    ], true),
    fields: builder.export(),
  });
  
  return TPath(path);
}

private final methods = [
  'POST',
  'GET',
  'HEAD',
  'PUT',
  'DELETE',
  'TRACE',
  'OPTIONS',
  'CONNECT',
  'PATCH'
];

private function validateHttpMethod(method:String) {
  return methods.contains(method);
}
