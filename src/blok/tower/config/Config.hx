package blok.tower.config;

import blok.tower.core.AppContext;
import blok.context.Context;
import blok.tower.core.SemVer;
import blok.data.Model;

using haxe.io.Path;

@:build(blok.tower.config.ConfigBuilder.build())
@:fallback(AppContext.from(context).container.get(Config))
class Config implements Context {
  @:prop public final name:String;
  
  @:prop 
  @:json(to = value.toString(), from = SemVer.parse(value))
  public final version:SemVer;
  
  @:prop
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
  public final type:AppType;
  
  @:prop 
  @:json(to = value.toJson(), from = PathConfig.fromJson(value))
  public final path:PathConfig;
  
  @:prop
  @:json(to = value.toJson(), from = RenderConfig.fromJson(value)) 
  public final render:RenderConfig;
  
  #if !blok.tower.client
  @:prop 
  @:json(to = value.toJson(), from = ServerConfig.fromJson(value))
  public final server:ServerConfig;
  
  @:prop
  @:json(to = value.toJson(), from = HaxeConfig.fromJson(value))
  public final haxe:HaxeConfig;
  
  @:prop
  @:json(to = value.toJson(), from = AssetConfig.fromJson(value))
  public final assets:AssetConfig;
  #end

  public function toClientJson() {
    var json:{} = toJson();
    Reflect.deleteField(json, 'server');
    Reflect.deleteField(json, 'haxe');
    Reflect.deleteField(json, 'assets');
    return json;
  }
}

@:build(blok.tower.config.ConfigBuilder.build())
class RenderConfig {
  @:prop public final root:String = 'root';
}

@:build(blok.tower.config.ConfigBuilder.build())
class PathConfig {
  @:prop public final staticPrefix:String = '';
  @:prop public final assetPath:String = 'assets';
  @:prop public final apiPrefix:String = 'api';
  @:prop public final apiPath:String = 'api';

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
@:build(blok.tower.config.ConfigBuilder.build())
class HaxeConfig {
  @:prop public final src:String = 'src';
  @:prop public final main:String = 'App';
  @:prop public final target:String = 'js';
  @:prop public final output:String = 'dist/build.js';
  @:json(from = value, to = value)
  @:prop public final dependencies:{
    shared:Array<String>,
    client:Array<String>,
    server:Array<String>
  } = { shared: [], client: [], server: [] };
  @:json(from = value, to = value)
  @:prop public final flags:{
    shared:{},
    client:{},
    server:{}
  } = { shared: [], client: [], server: [] };
}

@:build(blok.tower.config.ConfigBuilder.build())
class AssetConfig {
  @:prop public final src:String = 'data';
  @:prop public final privateDirectory:String = 'dist';
  @:prop public final publicDirectory:String = 'dist/public';
}

@:build(blok.tower.config.ConfigBuilder.build())
class ServerConfig {
  @:prop public final port:Int = 3000;
  // @todo: etc?
}
#end
