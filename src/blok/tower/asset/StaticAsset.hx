package blok.tower.asset;

import blok.tower.core.*;

using kit.Hash;

enum StaticAssetKind {
  External;
  Generated;
  Inline(content:String);
  Local(source:String);
}

abstract class StaticAsset implements Asset {
  final path:String;
  final kind:StaticAssetKind;
  final version:Null<SemVer>;

  public function new(path, kind, ver) {
    this.path = path;
    this.kind = kind;
    this.version = ver;
  }

  public function register(context:AssetContext) {
    #if !blok.tower.client
    switch kind {
      case External | Generated | Inline(_):
      case Local(source):
        context.output.add(new CopyOutput({
          key: path,
          source: source,
          dest: context.config.path.createAssetOutputPath(getPath())
        }));
    }
    modifyDocument(context, context.document);
    #end
  }

  public function getHash() {
    return (path + (version != null ? version.toFileNameSafeString() : '')).hash();
  }

  abstract function getPath():String;

  #if !blok.tower.client
  // @todo: Is this the right place for this?
  abstract function modifyDocument(context:AssetContext, document:Document):Void;
  #end
}
