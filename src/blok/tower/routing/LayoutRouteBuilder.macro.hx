package blok.tower.routing;

import blok.tower.macro.builder.*;
import blok.macro.*;
import haxe.macro.Context;
import haxe.macro.Expr;

using blok.macro.MacroTools;
using blok.tower.routing.macro.RouteScanner;
using haxe.macro.Tools;
using kit.Hash;

final builderFactory = new ClassBuilderFactory([
  new InjectFieldBuilder({
    buildConstructor: true,
    customBuilder: options -> {
      args: options.args,
      expr: macro {
        ${options.inits}
        var previousOwner = blok.signal.Graph.setCurrentOwner(Some(disposables));
        ${options.lateInits};
        ${switch options.previousExpr {
          case Some(expr): expr;
          case None: macro null;
        }}
        blok.signal.Graph.setCurrentOwner(previousOwner);
        disposables.addDisposable(this.routes);
      }
    }
  }),
  new LoadFieldBuilder({
    createHashPrefix: builder -> {
      var path = builder.getTypePath().typePathToArray().join('_');
      return macro $v{path};
    },
    createJsonAssetExportMethod: true
  })
]);

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, [
      TInst(_.get() => {kind: KExpr(macro $v{(pack:String)})}, _)
    ]):
      buildLayoutRoute(pack);
    default:
      throw 'assert';
  }
}

function build(pack:String) {
  return builderFactory
    .withBuilders(new LayoutRouteBuilder(pack))
    .fromContext()
    .export();
}

private function buildLayoutRoute(pack:String):ComplexType {
  var suffix = pack.hash();
  var name = 'LayoutRoute_${suffix}';
  var path:TypePath = { 
    pack: [ 'blok', 'tower', 'routing' ], 
    name: name, 
    params: [] 
  };

  if (path.typePathExists()) return TPath(path);
  
  var pos = Context.currentPos();
  var builder = new FieldBuilder([]);

  builder.add(macro class {
    private function render(context:blok.ui.ComponentBase, router:blok.ui.Child):blok.ui.Child;
  });

  Context.defineType({
    pack: path.pack,
    name: path.name,
    pos: pos,
    meta: [
      {
        name: ':autoBuild',
        params: [ macro blok.tower.routing.LayoutRouteBuilder.build($v{pack}) ],
        pos: pos
      },
      {
        name: ':remove',
        params: [],
        pos: pos
      }
    ],
    kind: TDClass(null, [
      {
        pack: [ 'blok', 'tower', 'routing' ],
        name: 'ViewRoute'
      },
      {
        pack: [ 'blok', 'tower', 'routing' ],
        name: 'LayoutRoute',
        sub: 'LayoutRouteMarker'
      }
    ], true),
    fields: builder.export()
  });

  return TPath(path);
}

class LayoutRouteBuilder implements Builder {
  public final priority:BuilderPriority = Normal;

  final pack:String;

  public function new(pack) {
    this.pack = pack;
  }

  public function apply(builder:ClassBuilder) {
    var views = pack.scanForViewRoutes();
    var routes:Array<Expr> = [];
    var routesBody:Array<Expr> = [];

    for (view in views) {
      var name = view.name;
      var type:ComplexType = TPath(view);
      routes.push(macro @:inject var $name:$type);
      routesBody.push(macro $i{name});
    }

    builder.addHook('init', macro {
      @:mergeBlock $b{routes};
      this.routes = new blok.tower.routing.ViewRouteCollection([ $a{routesBody} ]);
    });

    builder.add(macro class {
      static final pagesPackage = $v{pack};

      final routes:blok.tower.routing.ViewRouteCollection;
      final url = new blok.signal.Signal<String>('');
      final disposables = new blok.core.DisposableCollection();

      public function test(request:kit.http.Request):Bool {
        return routes.test(request);
      }
      
      public function match(request:kit.http.Request):kit.Maybe<blok.ui.Child> {
        if (test(request)) {
          url.set(request.url);
          var router = blok.tower.routing.ViewRouter.node({ routes: routes });
          return Some(Scope.wrap(context -> {
            var view = render(context, router);
            #if !blok.tower.client
            __exportJsonAssets(context);
            #end
            return view;
          }));
        }
        return None;
      }
      
      public function dispose() {
        disposables.dispose();
      }
    });
  }
}
