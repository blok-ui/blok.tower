package blok.tower.macro;

import blok.tower.config.AppType;
import haxe.macro.Context;

function isClient() {
  return Context.defined('blok.tower.client');
}

function getAppType():AppType {
  return switch Context.definedValue('blok.tower.type') {
    case 'dynamic': DynamicApp;
    default: StaticApp;
  }
}
