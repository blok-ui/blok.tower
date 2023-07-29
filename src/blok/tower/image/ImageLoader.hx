package blok.tower.image;

import blok.tower.asset.AssetContext;
import blok.ui.*;

class ImageLoader extends Component {
  @:observable final src:String;
  @:observable final size:ImageSize = ImageSize.Full;
  @:constant final child:(image:ImageAsset, assets:AssetContext)->Child;

  function render() {
    var config = ImageContext.from(this).config;
    var assets = AssetContext.from(this);
    var asset = new ImageAsset({
      path: src(),
      size: size(),
      config: config
    });
    assets.add(asset);
    return child(asset, assets);
  }
}
