package blok.tower.cli.command;

import blok.tower.cli.CommandTools;
import blok.tower.config.Config;
import blok.tower.file.FileSystem;

using Reflect;
using kit.Cli;
using haxe.io.Path;

class Build implements Command {
  final fs:FileSystem;
  final config:Config;

  public function new(fs, config) {
    this.fs = fs;
    this.config = config;
  }

  /**
    Setup all hxml files needed to compile your application. This is also
    required to ensure your editor can understand your application. After
    running setup, point your editor at the `*-server.hxml` file.
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
    Run the compiled app to generate the site (requires compile to be run first).
  **/
  @:command
  function visit():Task<Int> {
    output.writeLn('Running generator...');
    var cmd = [ createNodeCommand('node'), config.output.path ].join(' ');
    var code = try Sys.command(cmd) catch (e) {
      return new Error(InternalError, e.message);
    }
    if (code == 0) output.writeLn('Generated');
    return code;
  }

  /**
    Compile your application (requires setup to be run first).
  **/
  @:command
  function app():Task<Int> {
    output.writeLn('Compiling...');
    var cmd = [
      createNodeCommand('haxe'),
      getServerName()
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
  function all():Task<Int> {
    return setup()
      .next(code -> if (code == 0) app() else code)
      .next(code -> if (code == 0) visit() else code);
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
    var name = getSharedName();
    var dependencies = config.output.dependencies.shared ?? [];
    
    if (!dependencies.contains('blok.tower')) {
      dependencies.unshift('blok.tower');
    }

    var body = new StringBuf();

    body.add('-cp ${config.output.sourceFolder}\n\n');
    body.add('-D blok.tower.client.hxml=${getClientName().withoutExtension()}\n\n');
    
    for (item in dependencies) {
      body.add('-lib ${item}\n');
    }
    
    body.add('\n-main ${config.output.main}\n');

    return fs.createFile(name).write(body.toString()).next(_ -> Nothing);
  }

  function serverHxml():Task<Nothing> {
    var sharedName = getSharedName();
    var name = getServerName();
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
    var sharedName = getSharedName();
    var name = getClientName();
    var dependencies = config.output.dependencies.client ?? [];
    var body = new StringBuf();

    body.add(sharedName + '\n\n');
    
    for (item in dependencies) {
      body.add('-lib ${item}\n');
    }

    return fs.createFile(name).write(body.toString()).next(_ -> Nothing);
  }

  inline function getClientName() {
    return prepareHxmlName('client');
  }

  inline function getServerName() {
    return prepareHxmlName('server');
  }

  inline function getSharedName() {
    return prepareHxmlName('shared');
  }

  inline function prepareHxmlName(suffix:String) {
    return '${config.appName}-${suffix}.hxml';
  }
}
