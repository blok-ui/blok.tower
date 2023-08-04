package blok.tower.config;

import blok.tower.core.SemVer;
import blok.data.Model;

using haxe.io.Path;

class Config extends Model {
  @:constant public final name:String;
  @:json(
    to = value.toString(),
    from = SemVer.parse(value)
  )
  @:constant 
  public final version:SemVer;
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
  @:constant 
  public final type:AppType;
  #if !blok.tower.client
  @:json( to = null, from = null )
  @:constant 
  public final server:ServerConfig;
  @:json( to = null, from = null )
  @:constant 
  public final haxe:HaxeConfig;
  @:constant public final assets:AssetConfig;
  #end
  @:constant public final path:PathConfig;
}

#if !blok.tower.client
class HaxeConfig extends Model {
  @:constant public final src:String = 'src';
  @:constant public final main:String = 'App';
  @:constant public final target:String = 'js';
  @:constant public final output:String = 'dist/build.js';
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

class AssetConfig extends Model {
  @:constant public final src:String = 'data';
  @:constant public final privateDirectory:String = 'dist/data';
  @:constant public final publicDirectory:String = 'dist/public';
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
