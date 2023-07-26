package blok.tower.module;

import haxe.macro.Context;
import haxe.macro.Expr;
import blok.macro.ClassBuilder;

using Lambda;
using blok.tower.routing.macro.RouteScanner;
using haxe.macro.Tools;
using kit.Hash;
using blok.macro.MacroTools;

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, [ TInst(_.get() => {kind: KExpr(macro $v{(pack:String)})}, _) ]):
      buildLayoutModule(pack);
    default:
      Context.error('Invalid number of parameters -- expects one', Context.currentPos());
      null;
  }
}

private function buildLayoutModule(pack:String):ComplexType {
  var suffix = pack.hash();
  var name = 'LayoutModule_${suffix}';
  var path:TypePath = { pack: [ 'blok', 'tower', 'module' ], name: name, params: [] };

  if (path.typePathExists()) return TPath(path);
  
  var builder = new ClassBuilder([]);
  var layouts = pack.scanForLayoutRoutes();
  var routes = [ for (layout in layouts) {
    // We need to provide all the Layout's routes, which handily are
    // pointed to with the `pagesPackage` field. 
    var cls = Context.getType(layout.typePathToString()).getClass();
    var pagePack = switch cls.findField('pagesPackage', true) {
      case null: throw 'assert';
      case field: switch field.expr().expr {
        case TConst(TString(s)): s;
        default: 'assert';
      }
    }
    pagePack.scanForViewRoutes();
  } ].flatten();
  var registerLayouts:Array<Expr> = [ for (layout in layouts) {
    var path = layout.pack.concat([ layout.name ]);
    macro container.map($p{path}).to($p{path});
  } ];
  var registerRoutes:Array<Expr> = [ for (route in routes) {
    var path = route.pack.concat([ route.name ]);
    macro container.map($p{path}).to($p{path});
  } ];
  var addLayouts:Expr = if (layouts.length == 0) macro null else {
    macro router.addRoutes([ $a{layouts.map(tp -> {
      var path = tp.pack.concat([ tp.name ]);
      macro container.get($p{path});
    })} ]);
  }
  
  builder.add(macro class {
    public function new() {}

    public function provide(container:blok.tower.core.Container) {
      @:mergeBlock $b{registerRoutes};
      @:mergeBlock $b{registerLayouts};
      container.getMapping(blok.tower.core.Factory(blok.tower.routing.ViewRouteCollection)).extend(function (factory) {
        return factory.map(router -> {
          $addLayouts;
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