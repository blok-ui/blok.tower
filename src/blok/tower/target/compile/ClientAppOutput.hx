package blok.tower.target.compile;

import haxe.macro.Compiler;
import blok.tower.asset.*;
import blok.tower.cli.CommandTools;

using haxe.io.Path;

class ClientAppOutput implements OutputItem {
  public final key:OutputKey;
  
  final path:String;
  final target:Target;

  public function new(key, path, target) {
    this.key = key;
    this.path = path;
    this.target = target;
  }

  public function process(output:Output):Task<Nothing> {
    return Task.parallel(
      output.root.getFile(Sys.programPath()).next(f -> Some(f)).recover(_ -> Future.immediate(None)),
      output.pub.getFile(path).next(f -> Some(f)).recover(_ -> Future.immediate(None))
    ).next(files -> switch files {
      case [ Some(_), None ]:
        build(Path.join([ output.pub.path, path ]));
      case [ Some(a), Some(b) ] if (a.meta.updated.getTime() > b.meta.updated.getTime()):
        build(Path.join([ output.pub.path, path ]));
      case _:
        Nothing;
    });
  }

  function build(path:String):Task<Nothing> {
    try {
      var exitCode = Sys.command(getHaxeCommand(path));
      if (exitCode != 0) throw 'Compile failed';
      #if !debug
      var exit = Sys.command(getMinifyCommand(path));
      if (exit != 0) throw 'Compile failed';
      #end
      // @todo: Allow more commands to be run here?
    } catch (e) {
      return new Error(InternalError, e.message);
    }
    return Nothing;
  }

  function getHaxeCommand(path:String) {
    var hxml = Compiler.getDefine('blok.tower.client.hxml');
    
    if (hxml == null) hxml = 'client';

    hxml = hxml.withExtension('hxml');

    var cmd = [
      createNodeCommand('haxe'),
      '-lib blok.tower',
      hxml,
      '-D blok.tower.client',
      '-js ${path}'
    ];

    switch target {
      case StaticSiteGeneratedTarget:
        cmd.push('-D blok.tower.client.ssg');
      case ServerSideRenderTarget:
        cmd.push('-D blok.tower.client.ssr');
      default:
    }

    #if debug
    cmd.push('--debug');
    #end

    // @todo: however we decide to do plugins?

    return cmd.join(' ');
  }

  function getMinifyCommand(path:String) {
    return [
      createNodeCommand('uglifyjs'),
      path,
      '--compress',
      '--mangle',
      '-o ' + path.withExtension('min.js')
    ].join(' ');
  }
}
