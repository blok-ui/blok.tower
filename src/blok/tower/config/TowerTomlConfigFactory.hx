package blok.tower.config;

import blok.tower.core.SemVer;
import blok.tower.config.Config;

using haxe.io.Path;
using sys.io.File;
using Reflect;

class TowerTomlConfigFactory implements ConfigFactory {
  public function new() {}
  
  public function createConfig():Config {
    var contents = Path.join([ Sys.getCwd(), 'tower.toml' ]).getContent();
    var data:Dynamic = try Toml.parse(contents) catch (e) {
      throw new Error(InternalError, e.message);
    };
    var haxe:Dynamic = data.field('haxe') ?? {};
    var server:Dynamic = data.field('server') ?? {};
    var assets:Dynamic = data.field('assets') ?? {};
    var path:Dynamic = data.field('path') ?? {};
    var type:AppType = switch data.field('type') {
      case null: StaticApp;
      case 'static': StaticApp;
      case 'dynamic': DynamicApp;
      default:
        throw new Error(NotAcceptable, '`type` must be `static` or `dynamic`');
    }
    var appName = switch data.field('name') {
      case null: 
        throw new Error(NotFound, 'An app name is required');
      case name: 
        name;
    }
    var staticPrefix = switch path.field('staticPrefix') {
      case null if (type == DynamicApp): 
        '/public';
      case null:
        null;
      case other if (type == DynamicApp && other.length == 0):
        throw new Error(NotAcceptable, 'A static prefix is required for dynamic apps');
      case _ if (type != DynamicApp):
        throw new Error(NotAcceptable, 'No static prefix is allowed on static apps');
      case other:
        other;
    }

    return new Config({
      name: appName,
      version: SemVer.parse(data.field('version') ?? '0.0.1'),
      type: type,
      haxe: new HaxeConfig({
        output: haxe.field('output'),
        target: haxe.field('target'),
        main: haxe.field('main'),
        src: haxe.field('src'),
        dependencies: data.field('dependencies'),
        flags: haxe.field('flags')
      }),
      assets: new AssetConfig({
        src: assets.field('src'),
        publicDirectory: assets.field('public'),
        privateDirectory: assets.field('private'),
      }),
      path: new PathConfig({
        staticPrefix: staticPrefix,
        assetPath: path.field('assetPath'),
        apiPrefix: path.field('apiPrefix'),
        apiPath: path.field('apiPath')
      }),
      server: new ServerConfig({
        port: server.field('port')
      })
    });
  }
}
