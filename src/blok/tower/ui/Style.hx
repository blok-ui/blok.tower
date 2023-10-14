package blok.tower.ui;

import blok.html.Html;
import blok.tower.asset.StaticAsset.StaticAssetKind;
import blok.tower.core.SemVer;
import blok.ui.*;

class Style extends Component {
  @:attribute final src:String;
  @:attribute final kind:StaticAssetKind = External;
  @:attribute final version:Null<SemVer> = null;

  function render() {
    return Html.link({
      href: src,
      rel: 'stylesheet',
      dataset: [
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
