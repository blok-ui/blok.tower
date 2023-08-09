package blok.tower.asset;

class AssetBundle implements Asset {
  final assets:Array<Asset>;

  public function new(?assets) {
    this.assets = assets ?? [];
  }

  public function add(asset:Asset) {
    this.assets.push(asset);
  }

  public function register(context:AssetContext) {
    for (asset in assets) context.add(asset);
  }
}
