package blok.tower.config;

import blok.tower.core.AppContext;
import blok.context.Context;
import blok.tower.core.SemVer;
import blok.data.Model;

using haxe.io.Path;

@:fallback(AppContext.from(context).container.get(Config))
class Config extends Model implements Context {
  @:constant public final name:String;
  @:json(to = value.toString(), from = SemVer.parse(value))
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
  @:constant public final type:AppType;
  @:constant public final path:PathConfig;
  @:constant public final render:RenderConfig;
  #if !blok.tower.client
  @:constant public final server:ServerConfig;
  @:constant public final haxe:HaxeConfig;
  @:constant public final assets:AssetConfig;
  #end

  public function toClientJson() {
    var json:{} = toJson();
    Reflect.deleteField(json, 'server');
    Reflect.deleteField(json, 'haxe');
    Reflect.deleteField(json, 'assets');
    return json;
  }
}

class RenderConfig extends Model {
  @:constant public final root:String = 'root';
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
  @:constant public final privateDirectory:String = 'dist';
  @:constant public final publicDirectory:String = 'dist/public';
}

class ServerConfig extends Model {
  @:constant public final port:Int = 3000;
  // @todo: etc?
}
#end
