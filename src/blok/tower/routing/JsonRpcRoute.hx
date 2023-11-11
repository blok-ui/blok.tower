package blok.tower.routing;

// @todo: Deprecate this and replace it with blok.bridge methods.
@:genericBuild(blok.tower.routing.JsonRpcRouteBuilder.buildGeneric())
interface JsonRpcRoute<@:const Url> {}
