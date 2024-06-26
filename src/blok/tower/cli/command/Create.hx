package blok.tower.cli.command;

import kit.file.FileSystem;
import blok.tower.config.Config;
import haxe.Template;

using haxe.io.Path;
using kit.Cli;

class Create implements Command {
  /**
    Override the default root directory for the item you're creating.
  **/
  @:flag('d') var dir:String = null;

  /**
    Override the default package for the item you're creating.
  **/
  @:flag('p') var pack:String = null;

  /**
    Override the name of the app for the item you're creating.
  **/
  @:flag('a') var app:String = null;

  final config:Config;
  final fs:FileSystem;

  public function new(config, fs) {
    this.config = config;
    this.fs = fs;
  }

  /**
    Create a model.
  **/
  @:command
  function model(name:String):Task<Int> {
    var model = ModelTemplate.execute({
      app: app ?? config.name,
      pack: pack ?? 'model',
      name: name
    });
    var path = Path.join([
      dir ?? config.haxe.src,
      app ?? config.name,
      pack?.split('.')?.join('/') ?? 'model',
      name
    ]).withExtension('hx');
  
    displayCreationMessage(path);
    return fs.createFile(path).write(model).next(ok -> ok ? 0 : 1);
  }

  /**
    Create a JsonRpc route.
  **/
  @:command
  function api(name:String, path:String):Task<Int> {
    var api = ApiTemplate.execute({
      app: app ?? config.name,
      pack: pack ?? 'api',
      name: name,
      path: path
    });
    var path = Path.join([
      dir ?? config.haxe.src,
      app ?? config.name,
      pack?.split('.')?.join('/') ?? 'api',
      '${name}Api'
    ]).withExtension('hx');
  
    displayCreationMessage(path);
    return fs.createFile(path).write(api).next(ok -> ok ? 0 : 1);
  }

  /**
    Create a layout route.
  **/
  @:command
  function layout(name:String, ?target:String):Task<Int> {
    var layout = LayoutTemplate.execute({
      app: app ?? config.name,
      pack: pack ?? 'layout',
      name: name,
      target: target 
    });
    var path = Path.join([
      dir ?? config.haxe.src,
      app ?? config.name,
      pack?.split('.')?.join('/') ?? 'layout',
      '${name}Layout'
    ]).withExtension('hx');

    displayCreationMessage(path);
    return fs.createFile(path).write(layout).next(ok -> ok ? 0 : 1);
  }

  /**
    Create a page route.
  **/
  @:command
  function page(name:String, url:String):Task<Int> {
    var page = PageTemplate.execute({
      app: app ?? config.name,
      pack: pack ?? 'page',
      name: name,
      url: url
    });
    var path = Path.join([
      dir ?? config.haxe.src,
      app ?? config.name,
      pack?.split('.')?.join('/') ?? 'page',
      '${name}Page'
    ]).withExtension('hx');
    
    displayCreationMessage(path);
    return fs.createFile(path).write(page).next(ok -> ok ? 0 : 1);
  }

  /**
    Create a module.
  **/
  @:command
  function module(name:String):Task<Int> {
    var module = ModuleTemplate.execute({
      app: app ?? config.name,
      pack: pack ?? 'module',
      name: name,
    });
    var path = Path.join([
      dir ?? config.haxe.src,
      app ?? config.name,
      pack?.split('.')?.join('/') ?? 'module',
      '${name}Module'
    ]).withExtension('hx');
    
    displayCreationMessage(path);
    return fs.createFile(path).write(module).next(ok -> ok ? 0 : 1);
  }

  /**
    Quickly create various classes for Tower.
  **/
  @:defaultCommand
  function help():Task<Int> {
    output.write(getDocs());
    return 0;
  }

  function displayCreationMessage(fileName:String) {
    output.write('Outputting ').writeLn(fileName.bold());
  }
}

final ModelTemplate = new Template("package ::app::.::pack::;

import blok.data.Model;

class ::name:: extends Model {
  // Implement your model's fields here.
}
");

final ApiTemplate = new Template("package ::app::.::pack::;

import blok.tower.routing.JsonRpcRoute;

class ::name::Api implements JsonRpcRoute<'::path::'> {
  public function new() {}

  // Implement your API methods here. Every public method
  // will be exposed as a JSON RPC endpoint automatically,
  // so long as you return a `kit.Task<blok.data.Model>`.
}
");

final LayoutTemplate = new Template("package ::app::.::pack::;

import blok.ui.*;
import blok.tower.routing.LayoutRoute;

class ::name::Layout implements LayoutRoute<'::target::'> {
  function render(context:View, router:Child):Child {
    // Implement your layout here. Be sure to return `router`
    // somewhere or your app will not work!
  }
}
");

final PageTemplate = new Template("package ::app::.::pack::;

import blok.ui.*;
import blok.tower.routing.PageRoute;

class ::name::Page implements PageRoute<'::url::'> {
  public function render(context:View):Child {
    // Implement your page here.
  }
}
");

final ModuleTemplate = new Template("package ::app::.::pack::;

import blok.tower.core.*;

class ::name::Module implements Module {
  public function new() {}

  public function provide(container:Container) {
    // Implement your module here.
  }
}
");
