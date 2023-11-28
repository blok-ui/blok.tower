package blok.tower.core;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import blok.macro.*;

using haxe.macro.Tools;
using kit.Hash;
using blok.macro.MacroTools;

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, params):
      buildKernel(params);
    default:
      throw 'assert';
  }
}

private function buildKernel(types:Array<Type>) {  
  var pack = ['blok', 'tower', 'core'];
  var name = 'App_' + types.map(type -> type.stringifyTypeForClassName()).join('_').hash();
  var path:TypePath = { pack: pack, name: name };

  if (path.typePathExists()) return TPath(path);

  var builder = new FieldBuilder([]);
  var body:Array<Expr> = [];
  var pos = Context.currentPos();

  for (type in types) {
    if (!Context.unify(type, Context.getType('capsule.Module'))) {
      Context.error('All params must be capsule.Modules', Context.currentPos());
    }
    var path = type.toComplexType().toString().split('.');
    body.push(macro container.use($p{path}));
  }

  var pos = Context.currentPos();

  builder.add(macro class {
    public function new() {}

    public function provide(container:capsule.Container) {
      container.use(blok.tower.core.CoreModule);

      // @todo: This is Factory thing is weird and is only used to ensure
      // we have a dependency on Strategy.
      //
      // We should look into something like `container.require()`
      // for Capsule to resolve this better.
      container
        .map(blok.tower.core.Factory(blok.tower.target.Target))
        .to((strategy:blok.tower.target.Target) -> () -> strategy);
      container.map(blok.tower.core.ContainerFactory).to(this);
      
      $b{body};
    }

    public function createContainer():capsule.Container {
      return @:pos(pos) capsule.Container.build(this);
    }

    public function run() {
      return createContainer()
        .get(blok.tower.core.Factory(blok.tower.target.Target))
        .create()
        .run();
    }
  });

  Context.defineType({
    name: name,
    pack: pack,
    pos: (macro null).pos,
    kind: TDClass(null, [
      {
        pack: [ 'capsule' ],
        name: 'Module'
      },
      {
        pack: [ 'blok', 'tower', 'core' ],
        name: 'ContainerFactory'
      }
    ], false, true, false),
    fields: builder.export()
  });

  return TPath(path);
}
