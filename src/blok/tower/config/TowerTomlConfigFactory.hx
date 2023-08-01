package blok.tower.config;

import blok.tower.config.Config;
import blok.tower.target.Target;

using haxe.io.Path;
using sys.io.File;
using Reflect;

class TowerTomlConfigFactory implements ConfigFactory {
  final target:Target;

  public function new(target) {
    this.target = target;
  }
  
  public function createConfig():Config {
    var contents = Path.join([ Sys.getCwd(), 'tower.toml' ]).getContent();
    var data:Dynamic = try Toml.parse(contents) catch (e) {
      throw new Error(InternalError, e.message);
    };
    var output:Dynamic = data.field('output') ?? {};
    var server:Dynamic = data.field('server') ?? {};
    var path:Dynamic = data.field('path') ?? {};
    var appName = switch data.field('name') {
      case null: 
        throw new Error(NotFound, 'An app name is required');
      case name: 
        name;
    }
    var staticPrefix = switch path.field('staticPrefix') {
      case null if (target == ServerSideRenderingTarget): 
        '/public';
      case null:
        null;
      case other if (target == ServerSideRenderingTarget && other.length == 0):
        throw new Error(NotAcceptable, 'A static prefix is required for SSR targets');
      case _ if (target != ServerSideRenderingTarget):
        throw new Error(NotAcceptable, 'No static prefix is allowed on non-SSR targets');
      case other:
        other;
    }

    return new Config({
      appName: appName,
      output: new OutputConfig({
        path: output.field('path'),
        type: output.field('type'),
        main: output.field('main'),
        sourceFolder: output.field('sourceFolder'),
        dependencies: data.field('dependencies')
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
