package blok.tower.routing;

import haxe.macro.Context;
import haxe.macro.Expr;
import blok.macro.ClassBuilder;

using blok.tower.routing.macro.RouteBuilder;
using blok.tower.routing.internal.RouteParser;
using haxe.macro.Tools;
using kit.Hash;
using pine.macro.MacroTools;

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, [ 
      TInst(_.get() => {kind: KExpr(macro $v{(method:String)})}, _),
      TInst(_.get() => {kind: KExpr(macro $v{(url:String)})}, _),
      ret
    ]):
      buildApiEndpointRoute(method.toUpperCase(), url.normalizeUrl(), ret.toComplexType());
    default:
      throw 'assert';
  }
}

function build(method:String, url:String) {
  
}

function buildApiEndpointRoute(method:String, url:String, ret:ComplexType) {
  
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
