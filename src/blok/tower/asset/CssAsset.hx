package blok.tower.asset;

#if !blok.tower.client
import blok.html.server.*;
#end

using haxe.io.Path;

class CssAsset extends StaticAsset {
  public function getPath():String {
    return getHash().withExtension('css');
  }

  #if !blok.tower.client
  function modifyDocument(context:AssetContext, document:Document) {
    var head:ElementPrimitive = document.getHead();
    switch kind {
      case Inline(content):
        var style = new ElementPrimitive('style', {});
        style.append(new TextPrimitive(content));
        head.append(style);
      case External:
        head.append(new ElementPrimitive('link', {
          rel: 'stylesheet',
          href: path
        }));
      case Generated | Local(_): 
        head.append(new ElementPrimitive('link', {
          rel: 'stylesheet',
          href: context.config.path.createAssetUrl(getPath())
        }));
    }
  }
  #end
}
