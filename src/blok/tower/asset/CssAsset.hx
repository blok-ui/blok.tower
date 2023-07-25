package blok.tower.asset;

#if !blok.tower.client
import blok.html.server.*;
#end

using haxe.io.Path;

class CssAsset extends StaticAsset {
  public function getPath():String {
    return getHash().withExtension('css');
  }

  #if !forest.client
  function modifyDocument(context:AssetContext, document:Document) {
    var head:Element = document.getHead();
    head.append(new Element('link', {
      rel: 'stylesheet',
      href: switch kind {
        case External: path;
        case Generated | Local(_): 
          context.config.path.createAssetUrl(getPath());
      }
    }));
  }
  #end
}

