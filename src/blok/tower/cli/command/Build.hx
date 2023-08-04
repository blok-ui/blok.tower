package blok.tower.cli.command;

import blok.tower.cli.CommandTools;
import blok.tower.config.Config;
import blok.tower.file.FileSystem;

using Reflect;
using kit.Cli;
using haxe.io.Path;
using haxe.Json;

class Build implements Command {
  /**
    Set the resource folder. Defaults to `res`.
  **/
  @:flag('r') var res:String = 'res';

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

    This will also output your current configuration as a JSON file in
    your resource folder, which will be used to include it with the compiled
    application.
  **/
  @:command
  function setup():Task<Int> {
    output.writeLn('Setting up...');
    return Task.parallel(
      outputSharedHxml(),
      outputServerHxml(),
      outputClientHxml(),
      outputConfig()
    ).next(_ -> {
      output.writeLn('Setup complete.');
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

  function outputSharedHxml():Task<Nothing> {
    // @todo: Only output if __shared is stale.
    var name = getSharedName();
    var dependencies = config.output.dependencies.shared ?? [];
    
    if (!dependencies.contains('blok.tower')) {
      dependencies.unshift('blok.tower');
    }

    var body = new StringBuf();
    
    addGeneratedWarning(body);

    body.add('-cp ${config.output.src}\n\n');
    body.add('-D blok.tower.pre-configured\n');
    body.add('-D blok.tower.version=${config.version.toString()}\n');
    body.add('-D blok.tower.type=${config.type.toString()}\n');
    body.add('-D blok.tower.client.hxml=${getClientName().withoutExtension()}\n');
    addFlags(body, config.output.flags.shared);

    body.add('\n-resource ${getConfigResourcePath()}@blok.tower.config\n\n');
    
    for (item in dependencies) {
      body.add('-lib ${item}\n');
    }
    
    body.add('\n-main ${config.output.main}\n');

    return fs.createFile(name).write(body.toString()).next(_ -> Nothing);
  }

  function outputServerHxml():Task<Nothing> {
    var sharedName = getSharedName();
    var name = getServerName();
    var dependencies = config.output.dependencies.server ?? [];
    var body = new StringBuf();

    addGeneratedWarning(body);

    body.add('# Note: for haxe completion support, point your editor at THIS file.\n\n');

    body.add(sharedName + '\n\n');
    
    for (item in dependencies) {
      body.add('-lib ${item}\n');
    }

    addFlags(body, config.output.flags.server);

    body.add('\n');
    body.add('-${config.output.type} ${config.output.path}');

    return fs.createFile(name).write(body.toString()).next(_ -> Nothing);
  }

  function outputClientHxml():Task<Nothing> {
    var sharedName = getSharedName();
    var name = getClientName();
    var dependencies = config.output.dependencies.client ?? [];
    var body = new StringBuf();

    addGeneratedWarning(body);

    body.add(sharedName + '\n\n');
    
    for (item in dependencies) {
      body.add('-lib ${item}\n');
    }

    addFlags(body, config.output.flags.client);

    return fs.createFile(name).write(body.toString()).next(_ -> Nothing);
  }

  function outputConfig() {
    return fs
      .createFile(getConfigResourcePath())
      .write(config.toJson().stringify())
      .next(_ -> Nothing);
  }

  inline function getConfigResourcePath() {
    return Path.join([ res,  'blok-tower-config.json' ]);
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
    return '${config.name}-${suffix}.hxml';
  }

  function addGeneratedWarning(body:StringBuf) {
    body.add('# Automatically generated file. DO NOT EDIT!\n');
    body.add('# To configure things, edit your `tower.toml` and run\n');
    body.add('# `> tower build setup` or `> tower build all`\n\n');
  }

  function addFlags(body:StringBuf, flags:{}) {
    for (flag in flags.fields()) {
      var value:Dynamic = flags.field(flag);
      if (flag == 'debug') {
        body.add('--debug\n');
      } else if (flag == 'dce') {
        body.add('-dce ${value}\n');
      } else if (value == true) {
        body.add('-D $flag\n');
      } else {
        body.add('-D ${flag}=${value}\n');
      }
    }
  }
}
