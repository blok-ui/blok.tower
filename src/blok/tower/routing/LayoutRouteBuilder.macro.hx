package blok.tower.routing;

import blok.macro.ClassBuilder;
import haxe.macro.Context;
import haxe.macro.Expr;

using blok.macro.MacroTools;
using blok.tower.core.macro.InjectorBuilder;
using blok.tower.data.macro.LoaderBuilder;
using blok.tower.routing.macro.RouteScanner;
using haxe.macro.Tools;
using kit.Hash;

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
  var builder = ClassBuilder.fromContext();
  var cls = Context.getLocalClass().get();
  var clsPath = cls.pack.concat([ cls.name ]); 
  var pages = pack.scanForViewRoutes();

  if (pages.length == 0) {
    Context.error('No routes exist in the pack $pack. Make sure your path is correct', Context.currentPos());
  }

  var args:Array<FunctionArg> = [ for (page in pages) {
    name: page.pack.concat([ page.name ]).join('_'),
    type: TPath(page)
  }];
  var routes:Array<Expr> = [ for (arg in args) macro $i{arg.name} ];
  var loaderInfo = builder.processLoaders(macro $v{clsPath.join('_')});
  var injectInfo = builder.processInjectFields();

  for (name => type in loaderInfo.dependencies) {
    args.push({
      name: name,
      type: type
    });
    builder.add(macro class {
      final $name:$type;
    });
  }
  args = args.concat(injectInfo.args);

  builder.addField({
    name: 'new',
    access: [ APublic ],
    kind: FFun({
      args: args,
      expr: macro {
        @:mergeBlock $b{ [ for (name => _ in loaderInfo.dependencies) macro this.$name = $i{name} ] };
        @:mergeBlock $b{injectInfo.inits};
        var previousOwner = blok.signal.Graph.setCurrentOwner(Some(disposables));
        @:mergeBlock $b{loaderInfo.inits};
        this.routes = new blok.tower.routing.ViewRouteCollection([ $a{routes} ]);
        blok.signal.Graph.setCurrentOwner(previousOwner);
        disposables.addDisposable(this.routes);
      }
    }),
    pos: Context.currentPos()
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

  return builder.export();
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
  var builder = new ClassBuilder([]);

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
