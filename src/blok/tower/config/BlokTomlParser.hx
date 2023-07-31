package blok.tower.config;

import blok.tower.config.Config;
import blok.tower.file.FileSystem;
import blok.tower.target.Target;

using Reflect;

class BlokTomlParser {
  final fs:FileSystem;

  public function new(fs) {
    this.fs = fs;
  }

  public function load():Task<Config> {
    return fs.getFile('blok.toml')
      .next(file -> file.read())
      .next(contents -> {
        var data:Dynamic = try Toml.parse(contents) catch (e) {
          return new Error(InternalError, e.message);
        };
        var output:Dynamic = data.field('output') ?? {};
        var server:Dynamic = data.field('server') ?? {};
        var appName = switch data.field('app') {
          case null: 
            return new Error(NotFound, 'An app name is required');
          case name: name;
        }
        var target:Target = switch output.field('target') {
          case 'static': StaticSiteGeneratedTarget;
          case 'server': ServerSideRenderingTarget;
          case other: 
            return new Error(NotAcceptable, 'Invalid target: $other');
        }
        return new Config({
          appName: appName,
          output: new OutputConfig({
            name: output.field('name'),
            type: output.field('type'),
            main: output.field('type'),
            sourceFolder: output.field('sourceFolder'),
            target: target
          }),
          path: new PathConfig({}),
          server: new ServerConfig({
            port: server.field('port')
          })
        });
      });
  }
}
