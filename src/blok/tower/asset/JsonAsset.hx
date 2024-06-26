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

  public function register(context:AssetContext) {
    #if !blok.tower.client
    if (context.config.type.shouldOutputHtml()) context.output.add(new blok.tower.asset.CreateOutput({
      key: id,
      dest: context.config.path.createApiOutputPath(id).withExtension('json'),
      content: content
    }));

    var hydrationId = context.hydrationId;
    var head:ElementPrimitive = context.document.getHead();
    var script = new ElementPrimitive('script', { id: id });
    head.append(script);
    script.append(new TextPrimitive('(window.$hydrationId=window.$hydrationId||{})["$id"]=$content;'));
    #end
  }
}
