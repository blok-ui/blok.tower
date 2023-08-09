package blok.tower.asset;

import blok.tower.core.*;

using kit.Hash;

enum StaticAssetKind {
  /**
    Indicates a static asset that should be loaded from some
    external source.
  **/
  External;

  /**
    Indicates a static asset that has been generated by some other
    process and is already in the `config.path.assetPath` directory.
  **/
  Generated;

  /**
    Indicates a static asset that is available in the `source` directory
    and needs to be copied into the `config.path.assetPath` directory.
  **/
  Local(source:String);

  /**
    Indicates an asset whose content should be inlined into the HTML output.
  **/
  Inline(content:String);
}

abstract class StaticAsset implements Asset {
  final path:String;
  final kind:StaticAssetKind;
  final version:Null<SemVer>;

  public function new(path, kind, ?ver) {
    this.path = path;
    this.kind = kind;
    this.version = ver;
  }

  public function register(context:AssetContext) {
    #if !blok.tower.client
    switch kind {
      case External | Inline(_):
      case Generated:
        context.output.addToManifest(
          context.config.path.createAssetOutputPath(getPath())
        );
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
    return (path + (version != null ? '-' + version.toFileNameSafeString() : ''));
  }

  abstract function getPath():String;

  #if !blok.tower.client
  // @todo: Is this the right place for this?
  abstract function modifyDocument(context:AssetContext, document:Document):Void;
  #end
}
