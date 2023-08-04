package blok.tower.config;

import blok.tower.core.SemVer;
import blok.data.Model;

using haxe.io.Path;

// @todo: Not sure if this file really makes a lot of sense yet --
// the paradigm up to this point has been to include modules in
// the `App` constructor to configure things. However it *does*
// make sense to use this for the CLI, and there are a lot of 
// config things that benefit from being in one place, so...
//
// Also, `PathsConfig` is not used for figuring out file paths --
// that's all handled by mapping types in our Container. Either
// we should do that here *or* we should have those paths be handled
// by the Config too. We need more consistency.

class Config extends Model {
  @:constant public final name:String;
  @:json(
    to = value.toString(),
    from = SemVer.parse(value)
  )
  @:constant public final version:SemVer;
  @:json(
    to = switch value {
      case StaticApp: 'static';
      case DynamicApp: 'dynamic';
    },
    from = switch value {
      case 'dynamic': DynamicApp;
      default: StaticApp;
    }
  )
  @:constant public final type:AppType;
  #if !blok.tower.client
  @:json(
    to = null,
    from = null
  )
  @:constant public final server:ServerConfig;
  @:json(
    to = null,
    from = null
  )
  @:constant public final output:OutputConfig;
  #end
  @:constant public final path:PathConfig;
}

#if !blok.tower.client
class OutputConfig extends Model {
  @:constant public final path:String = 'dist/build.js';
  @:constant public final type:String = 'js';
  @:constant public final main:String = 'App';
  @:constant public final src:String = 'src';
  @:constant public final dependencies:{
    shared:Array<String>,
    client:Array<String>,
    server:Array<String>
  } = { shared: [], client: [], server: [] };
  @:constant public final flags:{
    shared:{},
    client:{},
    server:{}
  } = { shared: [], client: [], server: [] };
}

class ServerConfig extends Model {
  @:constant public final port:Int = 8080;
  // @todo: etc?
}
#end


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
