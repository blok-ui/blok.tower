package blok.tower.routing.macro;

import blok.tower.macro.ClassScanner;

function scanForViewRoutes(pack:String) {
  return scanForClasses(pack, 'blok.tower.routing.ViewRoute');
}

function scanForApiRoutes(pack:String) {
  return scanForClasses(pack, 'blok.tower.routing.ApiRoute');
}

function scanForLayoutRoutes(pack:String) {
  return scanForClasses(pack, 'blok.tower.routing.LayoutRoute.LayoutRouteMarker');
}
