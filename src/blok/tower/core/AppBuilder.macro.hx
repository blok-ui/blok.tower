package blok.tower.core;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import kit.macro.*;

using haxe.macro.Tools;
using kit.Hash;
using kit.macro.Tools;

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, params):
      buildApp(params);
    default:
      throw 'assert';
  }
}

private function buildApp(types:Array<Type>) {  
  var pack = ['blok', 'tower', 'core'];
  var name = 'App_' + types.map(type -> type.stringifyTypeForClassName()).join('_').hash();
  var path:TypePath = { pack: pack, name: name };

  if (path.typePathExists()) return TPath(path);

  var fields = new ClassFieldCollection([]);
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

  fields.add(macro class {
    public function new() {}

    public function provide(container:capsule.Container) {
      container.use(blok.tower.core.CoreModule);
      container.use(blok.tower.generate.GeneratorModule);
      $b{body};
    }

    public function createContainer():capsule.Container {
      return @:pos(pos) capsule.Container.build(this);
    }

    public function run() {
      return createContainer()
        .get(blok.tower.core.Factory(blok.tower.generate.Target))
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
    fields: fields.export()
  });

  return TPath(path);
}
