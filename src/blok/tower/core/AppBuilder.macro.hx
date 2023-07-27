package blok.tower.core;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import blok.macro.ClassBuilder;

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

  var builder = new ClassBuilder([]);
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

      container.map(blok.tower.target.StrategyResolver).to(blok.tower.target.StrategyResolver);
      container.map(blok.tower.core.ContainerFactory).to(this);
      
      $b{body};
    }

    public function createContainer():capsule.Container {
      return @:pos(pos) capsule.Container.build(this);
    }

    public function run() {
      return createContainer()
        .get(blok.tower.target.StrategyResolver)
        .get()
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