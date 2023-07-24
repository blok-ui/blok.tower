package blok.tower.ui;

import blok.html.Html;
import blok.tower.asset.StaticAsset.StaticAssetKind;
import blok.tower.core.SemVer;
import blok.ui.*;

class Style extends Component {
  @:constant final src:String;
  @:constant final kind:StaticAssetKind = External;
  @:constant final version:SemVer = null;

  function render() {
    return Html.link({
      href: src,
      rel: 'stylesheet',
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
