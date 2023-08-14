package blok.tower.routing;

@:genericBuild(blok.tower.routing.ApiEndpointRouteBuilder.buildGeneric())
interface ApiEndpointRoute<@:const Method, @:const Path> {}
