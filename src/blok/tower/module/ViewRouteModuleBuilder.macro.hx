package blok.tower.module;

import blok.macro.*;
import haxe.macro.Context;
import haxe.macro.Expr;

using blok.tower.routing.macro.RouteScanner;
using blok.macro.MacroTools;
using kit.Hash;

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, [ TInst(_.get() => {kind: KExpr(macro $v{(pack:String)})}, _) ]):
      buildViewRouteModule(pack);
    default:
      Context.error('Invalid number of parameters -- expect one', Context.currentPos());
      null;
  }
}

private function buildViewRouteModule(pack:String):ComplexType {
  var suffix = pack.hash();
  var name = 'ViewRouteModule_${suffix}';
  var path:TypePath = { pack: [ 'blok', 'tower', 'module' ], name: name, params: [] };

  if (path.typePathExists()) return TPath(path);
  
  var builder = new FieldBuilder([]);
  var routes = pack.scanForViewRoutes();
  var registerRoutes:Array<Expr> = [ for (route in routes) {
    var path = route.pack.concat([ route.name ]);
    macro container.map($p{path}).to($p{path});
  } ];
  var addRoutes:Expr = if (routes.length == 0) macro null else {
    macro router.addRoutes([ $a{routes.map(tp -> {
      var path = tp.pack.concat([ tp.name ]);
      macro container.get($p{path});
    })} ]);
  }
  
  builder.add(macro class {
    public function new() {}

    public function provide(container:blok.tower.core.Container) {
      @:mergeBlock $b{registerRoutes};
      container.getMapping(blok.tower.core.Factory(blok.tower.routing.ViewRouteCollection)).extend(function (factory) {
        return factory.map(router -> {
          $addRoutes;
          router;
        });
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
    fields: builder.export()
  });

  return TPath(path);
}
