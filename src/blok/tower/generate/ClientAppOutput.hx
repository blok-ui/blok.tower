package blok.tower.generate;

import blok.tower.config.Config;
import haxe.macro.Compiler;
import blok.tower.asset.*;
import blok.tower.cli.CommandTools;

using haxe.io.Path;

class ClientAppOutput implements OutputItem {
  public final key:OutputKey;
  
  final path:String;
  final config:Config;

  public function new(key, path, config) {
    this.key = key;
    this.path = path;
    this.config = config;
  }

  public function process(output:Output):Task<Nothing> {
    output.addToManifest(path);

    #if debug
    output.addToManifest(path.withExtension('js.map'));
    #else
    output.addToManifest(path.withExtension('min.js'));
    #end

    return Task.parallel(
      output.root.getFile(Sys.programPath()).next(f -> Some(f)).recover(_ -> Future.immediate(None)),
      output.pub.getFile(path).next(f -> Some(f)).recover(_ -> Future.immediate(None))
    ).next(files -> switch files {
      case [ Some(_), None ]:
        build(Path.join([ output.pub.meta.path, path ]));
      case [ Some(a), Some(b) ] if (a.meta.updated.getTime() > b.meta.updated.getTime()):
        build(Path.join([ output.pub.meta.path, path ]));
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
