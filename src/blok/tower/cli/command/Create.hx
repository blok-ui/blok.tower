package blok.tower.cli.command;

import blok.tower.file.FileSystem;
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

  final config:Task<Config>;
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
    return 0;
  }

  /**
    Create a JsonRpc route.
  **/
  @:command
  function api(name:String, path:String):Task<Int> {
    return 0;
  }

  /**
    Create a layout route.
  **/
  @:command
  function layout(name:String, ?pack:String):Task<Int> {
    return 0;
  }

  /**
    Create a page route.
  **/
  @:command
  function page(name:String, url:String):Task<Int> {
    return config.next(config -> {
      var page = PageTemplate.execute({
        app: app ?? config.appName,
        pack: pack ?? 'page',
        name: name,
        url: url
      });
      var path = Path.join([ 
        dir ?? config.output.sourceFolder,
        app ?? config.appName,
        pack?.split('.')?.join('/') ?? 'page',
        '${name}Page'
      ]).withExtension('hx');
      
      output.writeLn(page);
  
      output.write(
        'Creating page ',
        name.color(White).backgroundColor(Blue).bold(),
        ' in file ', 
        path.color(White).backgroundColor(Blue).bold()
      );
  
      return 0;
      // return fs.createFile(path).write(page).next(_ -> 0);
    });
  }

  /**
    Quickly create various classes for Tower.
  **/
  @:defaultCommand
  function help():Task<Int> {
    output.write(getDocs());
    return 0;
  }
}

final PageTemplate = new Template("package ::app::.::pack::;

import blok.ui.*;
import blok.tower.routing.PageRoute;

class ::name::Page implements PageRoute<'::url::'> {
  public function render(context:ComponentBase):Child {
    // Implement your page here.
  }
}
");
