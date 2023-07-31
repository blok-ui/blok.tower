package blok.tower.config;

import blok.tower.target.Target;
import blok.data.Model;

using haxe.io.Path;

// @todo: Not sure if this file really makes a lot of sense yet --
// we're not using config for anything but path config really.
//
// Even then, we're not using it for figuring out file paths --
// that's all handled by mapping types in our Container. Either
// we should do that here *or* we should have those paths be handled
// by the Config too. 

class Config extends Model {
  @:constant public final appName:String;
  @:constant public final server:ServerConfig;
  @:constant public final output:OutputConfig;
  @:constant public final path:PathConfig;
}

class OutputConfig extends Model {
  @:constant public final name:String = 'build';
  @:constant public final type:String = 'js';
  @:constant public final main:String = 'App';
  @:constant public final sourceFolder:String = 'src';
  @:constant public final dependencies:{
    shared:Array<String>,
    client:Array<String>,
    server:Array<String>
  } = { shared: [], client: [], server: [] };
  @:constant public final target:Target;

  public function shouldOutputHtml() {
    return switch target {
      case StaticSiteGeneratedTarget: true;
      default: false;
    }
  }
}

class ServerConfig extends Model {
  @:constant public final port:Int = 8080;
  // @todo: etc?
}

class PathConfig extends Model {
  @:constant public final staticPrefix:String = '';
  @:constant public final assetPath:String = 'assets';
  @:constant public final apiPrefix:String = 'api';
  @:constant public final apiPath:String = 'api';

  public function createAssetUrl(path:String) {
    return Path.join([ '/', staticPrefix, assetPath, path ]);
  }

  public function createAssetOutputPath(path:String) {
    return Path.join([ '/', assetPath, path ]);
  }

  public function createApiUrl(path:String) {
    return Path.join([ '/', apiPrefix, path ]);
  }

  public function createApiOutputPath(path:String) {
    return Path.join([ '/', apiPath, path ]);
  }
}
