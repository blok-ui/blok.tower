package blok.tower.ui;

import blok.tower.core.SemVer;
import blok.tower.asset.StaticAsset.StaticAssetKind;
import blok.ui.*;
import blok.html.Html;

class Script extends Component {
  @:constant final src:String;
  @:constant final type:String = 'text/javascript';
  @:constant final kind:StaticAssetKind = External;
  @:constant final version:SemVer = null;
  
  function render() {
    return Html.script({
      src: src,
      type: type,
      dataset: [
        'source' => switch kind {
          case Local(source): source;
          default: null;
        },
        'sem-ver' => version?.toString()
      ]
    });
  }
}
