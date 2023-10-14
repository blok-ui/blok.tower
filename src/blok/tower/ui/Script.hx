package blok.tower.ui;

import blok.tower.core.SemVer;
import blok.tower.asset.StaticAsset.StaticAssetKind;
import blok.ui.*;
import blok.html.Html;

class Script extends Component {
  @:attribute final src:String;
  @:attribute final type:String = 'text/javascript';
  @:attribute final kind:StaticAssetKind = External;
  @:attribute final version:SemVer = null;
  
  function render() {
    return Html.script({
      src: src,
      type: type,
      dataset: [
        'inline' => switch kind {
          case Inline(content): content;
          default: null; 
        },
        'generated' => switch kind {
          case Generated: 'generated';
          default: null;
        },
        'source' => switch kind {
          case Local(source): source;
          default: null;
        },
        'sem-ver' => version?.toString()
      ]
    });
  }
}
