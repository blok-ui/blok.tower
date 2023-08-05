package blok.tower.image;

import blok.data.Model;
import blok.tower.asset.*;

using haxe.io.Path;
using kit.Hash;

@:allow(blok.tower.image)
class ImageAsset extends Model implements Asset {
  #if blok.tower.client
  // @todo: Use Cache?
  static final loaders:Map<String, ClientImageLoader> = [];
  #end

  @:constant final path:String;
  @:constant final size:ImageSize;
  @:constant final config:ImageConfig;

  public function register(context:AssetContext) {
    #if !blok.tower.client
    context.output.add(new ImageOutput({
      key: getHash(),
      source: path,
      dest: context.config.path.createAssetOutputPath(getBasePath()),
      image: this
    }));
    #end
  }
  
  public function load(context:AssetContext, immediate:Bool):Task<String> {
    var url = context.config.path.createAssetUrl(getBasePath());
    #if !blok.tower.client
    return url;
    #else
    if (immediate) return url;
    if (loaders.exists(url)) return loaders.get(url);
    var loader = new ClientImageLoader(url);
    loaders.set(url, loader);
    return loader;
    #end
  }

  public function getHash() {
    var suffix = switch size {
      case Full: 'full';
      case Medium: 'md';
      case Thumbnail: 'thumb';
      case Custom(x, y): 'c-$x-$y';
    }
    return (path + suffix).hash();
  }

  public function getBasePath() {
    var ext = path.extension();
    return Path.join([
      'images',
      getHash()
    ]).withExtension(ext);
  }
}
