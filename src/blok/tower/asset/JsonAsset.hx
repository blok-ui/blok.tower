package blok.tower.asset;

import blok.data.Record;
#if !blok.tower.client
import blok.html.server.*;
#end

using Reflect;
using haxe.io.Path;

class JsonAsset extends Record implements Asset {
  @:constant final id:String;
  @:constant final content:String;
  @:constant final hydrationId:String;

  public function register(context:AssetContext) {
    #if !blok.tower.client
    switch context.target {
      case StaticSiteGeneratedTarget:
        context.output.add(new blok.tower.asset.CreateOutput({
          key: id,
          dest: Path.join([
            'api', // @todo: Make this configurable
            id 
          ]).withExtension('json'),
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
