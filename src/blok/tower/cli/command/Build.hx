package blok.tower.cli.command;

import blok.tower.cli.CommandTools;
import blok.tower.config.Config;
import blok.tower.file.FileSystem;

using Reflect;
using kit.Cli;
using haxe.io.Path;
using haxe.Json;
using StringTools;

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
    var cmd = [ createNodeCommand('node'), config.haxe.output ].join(' ');
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
  function compile():Task<Int> {
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
    Build the app for production.
  **/
  @:command
  function production():Task<Int> {
    config.haxe.flags.shared.setField('debug', 'false');
    return setup()
      .next(code -> if (code == 0) compile() else code)
      .next(code -> if (code == 0) visit() else code);
  }

  /**
    Compile for development and start up a server.
  **/
  @:command
  function dev():Task<Int> {
    config.haxe.flags.shared.setField('debug', 'true');
    return setup()
      .next(code -> if (code == 0) compile() else code)
      .next(code -> if (code == 0) visit() else code);
    // @todo: start the server.
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
    var dependencies = config.haxe.dependencies.shared ?? [];
    
    if (!dependencies.contains('blok.tower')) {
      dependencies.unshift('blok.tower');
    }

    var body = new StringBuf();
    
    addGeneratedWarning(body);

    body.add('-cp ${config.haxe.src}\n\n');
    body.add('-D blok.tower.pre-configured\n');
    body.add('-D blok.tower.version=${config.version.toString()}\n');
    body.add('-D blok.tower.type=${config.type.toString()}\n');
    body.add('-D blok.tower.client.hxml=${getClientName().withoutExtension()}\n');
    addFlags(body, config.haxe.flags.shared);
    
    for (item in dependencies) {
      body.add('-lib ${item}\n');
    }
    
    body.add('\n-main ${config.haxe.main}\n');

    return fs.createFile(name).write(body.toString()).next(_ -> Nothing);
  }

  function outputServerHxml():Task<Nothing> {
    var sharedName = getSharedName();
    var name = getServerName();
    var dependencies = config.haxe.dependencies.server ?? [];
    var body = new StringBuf();

    addGeneratedWarning(body);

    body.add('# Note: for haxe completion support, point your editor at THIS file.\n\n');

    body.add(sharedName + '\n\n');
    
    for (item in dependencies) {
      body.add('-lib ${item}\n');
    }

    addConfigResource(body, 'server');
    addFlags(body, config.haxe.flags.server);

    body.add('\n');
    body.add('-${config.haxe.target} ${config.haxe.output}');

    return fs.createFile(name).write(body.toString()).next(_ -> Nothing);
  }

  function outputClientHxml():Task<Nothing> {
    var sharedName = getSharedName();
    var name = getClientName();
    var dependencies = config.haxe.dependencies.client ?? [];
    var body = new StringBuf();

    addGeneratedWarning(body);

    body.add(sharedName + '\n\n');
    
    for (item in dependencies) {
      body.add('-lib ${item}\n');
    }

    addConfigResource(body, 'client');
    addFlags(body, config.haxe.flags.client);

    return fs.createFile(name).write(body.toString()).next(_ -> Nothing);
  }

  function outputConfig() {
    return Task.parallel(
      fs.createFile(getConfigResourcePath('server'))
        .write(config.toJson().stringify()),
      fs.createFile(getConfigResourcePath('client'))
        .write(config.toClientJson().stringify())
    ).next(_ -> Nothing);
  }

  inline function getConfigResourcePath(type:String) {
    return Path.join([ res,  'blok-tower-config-${type}.json' ]);
  }

  inline function addConfigResource(body:StringBuf, type:String) {
    body.add('-resource ${getConfigResourcePath(type)}@blok.tower.config\n\n');
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
    body.add('# `> tower build setup`.\n\n');
  }

  function addFlags(body:StringBuf, flags:{}) {
    var version = config.version.toFileNameSafeString();

    for (flag in flags.fields()) {
      var value:Dynamic = flags.field(flag);
      if (flag == 'debug') {
        if (value == 'true') body.add('--debug\n');
      } else if (flag == 'dce') {
        body.add('-dce ${value}\n');
      } else if (flag == 'macro') {
        body.add('--macro ${value}\n');
      } else if (value == true) {
        body.add('-D $flag\n');
      } else {
        // @todo: Think up a better way to do this.
        var str = Std.string(value).replace('{{version}}', version);
        body.add('-D ${flag}=${str}\n');
      }
    }
  }
}
