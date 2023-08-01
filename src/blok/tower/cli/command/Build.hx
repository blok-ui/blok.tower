package blok.tower.cli.command;

import blok.tower.cli.CommandTools;
import blok.tower.config.Config;
import blok.tower.file.FileSystem;

using Reflect;
using kit.Cli;

class Build implements Command {
  final fs:FileSystem;
  final config:Config;

  public function new(fs, config) {
    this.fs = fs;
    this.config = config;
  }

  /**
    Run the compiled app to generate the site (requires compile to be run first).
  **/
  @:command
  function generate():Task<Int> {
    output.writeLn('Running generator...');
    var cmd = [ createNodeCommand('node'), config.output.path ].join(' ');
    var code = try Sys.command(cmd) catch (e) {
      return new Error(InternalError, e.message);
    }
    if (code == 0) output.writeLn('Generated');
    return code;
  }

  /**
    Setup all hxml files needed to compile your application.
  **/
  @:command
  function setup():Task<Int> {
    output.writeLn('Creating artifacts...');
    return Task.parallel(
      sharedHxml(),
      serverHxml(),
      clientHxml()
    ).next(_ -> {
      output.writeLn('Artifacts created.');
      return 0;
    });
  }

  /**
    Compile your application (requires setup to be run first).
  **/
  @:command
  function compile():Task<Int> {
    output.writeLn('Compiling...');
    var cmd = [
      createNodeCommand('haxe'),
      '__${config.appName}-server.hxml'
    ].join(' ');
    var code = try Sys.command(cmd) catch (e) {
      return new Error(InternalError, e.message);
    }
    if (code == 0) output.writeLn('Compiled');
    return code;
  }

  /**
    Execute all build steps.
  **/
  @:command
  function build():Task<Int> {
    return setup()
      .next(code -> if (code == 0) compile() else code)
      .next(code -> if (code == 0) generate() else code);
  }

  /**
    Compile and generate your Tower site.
  **/
  @:defaultCommand
  function help():Task<Int> {
    output.writeLn(getDocs());
    return 0;
  }

  function sharedHxml():Task<Nothing> {
    // @todo: Only output if __shared is stale.
    var name = '__${config.appName}-shared.hxml';
    var dependencies = config.output.dependencies.shared ?? [];
    
    if (!dependencies.contains('blok.tower')) {
      dependencies.unshift('blok.tower');
    }

    var body = new StringBuf();

    body.add('-cp ${config.output.sourceFolder}\n\n');
    body.add('-D blok.tower.client.hxml=__${config.appName}-client\n\n');
    
    for (item in dependencies) {
      body.add('-lib ${item}\n');
    }
    
    body.add('\n-main ${config.output.main}\n');

    return fs.createFile(name).write(body.toString()).next(_ -> Nothing);
  }

  function serverHxml():Task<Nothing> {
    var sharedName = '__${config.appName}-shared.hxml';
    var name = '__${config.appName}-server.hxml';
    var dependencies = config.output.dependencies.server ?? [];
    var body = new StringBuf();

    body.add(sharedName + '\n\n');
    
    for (item in dependencies) {
      body.add('-lib ${item}\n');
    }

    body.add('\n');
    body.add('-${config.output.type} ${config.output.path}');

    return fs.createFile(name).write(body.toString()).next(_ -> Nothing);
  }

  function clientHxml():Task<Nothing> {
    var sharedName = '__${config.appName}-shared.hxml';
    var name = '__${config.appName}-client.hxml';
    var dependencies = config.output.dependencies.client ?? [];
    var body = new StringBuf();

    body.add(sharedName + '\n\n');
    
    for (item in dependencies) {
      body.add('-lib ${item}\n');
    }

    return fs.createFile(name).write(body.toString()).next(_ -> Nothing);
  }
}
