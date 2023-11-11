package blok.tower.routing;

// @todo: Deprecate this and replace it with blok.bridge methods.
@:genericBuild(blok.tower.routing.ApiEndpointRouteBuilder.buildGeneric())
interface ApiEndpointRoute<@:const Method, @:const Path> {}
