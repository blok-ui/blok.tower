package blok.tower.asset;

#if !blok.tower.client
import blok.html.server.*;
#end

using haxe.io.Path;

class JsAsset extends StaticAsset {
  public function getPath():String {
    return getHash().withExtension('js');
  }

  #if !blok.tower.client
  function modifyDocument(context:AssetContext, document:Document) {
    var head:ElementPrimitive = document.getHead();
    switch kind {
      case Inline(content):
        var script = new ElementPrimitive('script', { type: 'text/javascript' });
        script.append(new TextPrimitive(content));
        head.append(script);
      case External:
        head.append(new ElementPrimitive('script', {
          src: path,
          defer: true,
          type: 'text/javascript'
        }));
      case Generated | Local(_): 
        head.append(new ElementPrimitive('script', {
          src: context.config.path.createAssetUrl(getPath()),
          defer: true,
          type: 'text/javascript'
        }));
    }
  }
  #end
}
