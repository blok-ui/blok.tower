package blok.tower.module;

import haxe.macro.Context;
import haxe.macro.Expr;
import blok.macro.ClassBuilder;

using kit.Hash;
using blok.macro.MacroTools;

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, [ 
      TInst(_.get() => {kind: KExpr(macro $v{(src:String)})}, _),
      TInst(_.get() => {kind: KExpr(macro $v{(pub:String)})}, _),
      TInst(_.get() => {kind: KExpr(macro $v{(priv:String)})}, _),
    ]):
      buildAssetModule(src, pub, priv);
    default:
      Context.error('Invalid number of parameters -- expected exactly three', Context.currentPos());
  }
}

function buildAssetModule(src:String, pub:String, priv:String) {
  var suffix = '${src}_${pub}_${priv}'.hash();
  var name = 'AssetPathModule_$suffix';
  var modulePath:TypePath = { pack: [ 'blok', 'tower', 'module' ], name: name };

  if (modulePath.typePathExists()) return TPath(modulePath);

  var builder = new ClassBuilder([]);
  
  builder.add(macro class {
    public function new() {}

    public function provide(container:blok.tower.core.Container) {
      #if !blok.tower.client
      container.map(blok.tower.asset.data.SourceDirectory)
        .to((fs:blok.tower.file.FileSystem) -> fs.openDirectory($v{src}))
        .share();
      container.map(blok.tower.asset.data.PublicDirectory)
        .to((fs:blok.tower.file.FileSystem) -> fs.openDirectory($v{pub}))
        .share();
      container.map(blok.tower.asset.data.PrivateDirectory)
        .to((fs:blok.tower.file.FileSystem) -> fs.openDirectory($v{priv}))
        .share();
      #end
    }
  });

  Context.defineType({
    pack: modulePath.pack,
    name: modulePath.name,
    pos: Context.currentPos(),
    kind: TDClass(null, [
      {
        pack: [ 'blok', 'tower', 'core' ],
        name: 'Module'
      }
    ], false, true),
    fields: builder.export()
  });
  
  return TPath(modulePath);
}
