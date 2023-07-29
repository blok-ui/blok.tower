package blok.tower.routing;

import blok.data.Model;

@:genericBuild(blok.tower.routing.ApiEndpointRouteBuilder.buildGeneric())
interface ApiEndpointRoute<@:const Method, @:const Path> {}
