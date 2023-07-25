package blok.tower.asset;

import blok.data.Model;
#if !blok.tower.client
import blok.html.server.*;
#end

using Reflect;
using haxe.io.Path;

class JsonAsset extends Model implements Asset {
  @:constant final id:String;
  @:constant final content:String;
  @:constant final hydrationId:String;

  public function register(context:AssetContext) {
    #if !blok.tower.client
    switch context.config.output.target {
      case StaticSiteGeneratedTarget:
        context.output.add(new blok.tower.asset.CreateOutput({
          key: id,
          dest: context.config.path.createApiOutputPath(id).withExtension('json'),
          content: content
        }));
      default:
    }

    var head:Element = context.document.getHead();
    var script = new Element('script', { id: id });
    head.append(script);
    script.append(new TextNode('(window.$hydrationId=window.$hydrationId||{})["$id"]=$content;', false));
    #end
  }
}
