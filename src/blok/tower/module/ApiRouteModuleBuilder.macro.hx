package blok.tower.module;

import haxe.macro.Context;
import haxe.macro.Expr;
import kit.macro.*;

using blok.tower.routing.macro.RouteScanner;
using kit.macro.Tools;
using kit.Hash;

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, [ TInst(_.get() => {kind: KExpr(macro $v{(pack:String)})}, _) ]):
      buildApiRouteModule(pack);
    default:
      Context.error('Invalid number of parameters -- expect one', Context.currentPos());
      null;
  }
}

private function buildApiRouteModule(pack:String):ComplexType {
  var suffix = pack.hash();
  var name = 'ApiRouteModule_${suffix}';
  var path:TypePath = { pack: [ 'blok', 'tower', 'module' ], name: name, params: [] };

  if (path.typePathExists()) return TPath(path);
  
  var fields = new ClassFieldCollection([]);
  var routes = pack.scanForApiRoutes();
  var registerRoutes:Array<Expr> = [ for (route in routes) {
    var path = route.pack.concat([ route.name ]);
    macro container.map($p{path}).toShared($p{path});
  } ];
  var addRoutes:Expr = if (routes.length == 0) macro null else {
    macro router.addRoutes([ $a{routes.map(tp -> {
      var path = tp.pack.concat([ tp.name ]);
      macro container.get($p{path});
    })} ]);
  }
  
  fields.add(macro class {
    public function new() {}

    public function provide(container:blok.tower.core.Container) {
      @:mergeBlock $b{registerRoutes};
      container.getMapping(blok.tower.routing.ApiRouteCollection).extend(function (router) {
        $addRoutes;
        return router;
      });
    }
  });

  Context.defineType({
    pack: path.pack,
    name: path.name,
    pos: Context.currentPos(),
    kind: TDClass(null, [
      {
        pack: [ 'blok', 'tower', 'core' ],
        name: 'Module'
      }
    ], false, true),
    fields: fields.export()
  });

  return TPath(path);
}
