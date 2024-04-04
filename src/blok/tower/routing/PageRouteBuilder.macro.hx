package blok.tower.routing;

import blok.macro.*;
import blok.tower.macro.builder.*;
import haxe.macro.Context;
import haxe.macro.Expr;

using blok.macro.MacroTools;
using blok.tower.routing.macro.RouteBuilder;
using kit.Hash;

final builderFactory = new ClassBuilderFactory([
  new LoadFieldBuilder({
    createJsonAssetExportMethod: true,
    createHashPrefix: _ -> macro kit.Hash.hash(url.get())
  }),
  new InjectFieldBuilder({
    buildConstructor: true,
    customBuilder: options -> {
      args: options.args,
      expr: macro {
        ${options.inits};
        var previousOwner = blok.core.Owner.setCurrent(disposables);
        ${options.lateInits};
        blok.core.Owner.setCurrent(previousOwner);
        ${switch options.previousExpr {
          case Some(expr): expr;
          case None: macro null;
        }}
      }
    }
  })
]);

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, [ TInst(_.get() => {kind: KExpr(macro $v{(url:String)})}, _) ]):
      buildPageRoute(url.normalizeUrl());
    default:
      throw 'assert';
  }
}

function build(url:String) {
  return builderFactory
    .withBuilders(new PageRouteBuilder(url))
    .fromContext()
    .export();
}

private function buildPageRoute(url:String) {
  var suffix = url.hash();
  var pos = Context.getLocalClass().get().pos;
  var pack = [ 'blok', 'tower', 'routing' ];
  var name = 'PageRoute_${suffix}';
  var path:TypePath = { pack: pack, name: name, params: [] };

  if (path.typePathExists()) return TPath(path);

  var builder = new FieldBuilder([]);

  builder.add(macro class {
    private function render(context:blok.ui.View):blok.ui.Child;
  });

  Context.defineType({
    pack: pack,
    name: name,
    pos: pos,
    meta: [
      {
        name: ':autoBuild',
        params: [ macro blok.tower.routing.PageRouteBuilder.build($v{url}) ],
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
      }
    ], true, false, false),
    fields: builder.export()
  });

  return TPath(path);
}

class PageRouteBuilder implements Builder {
  public final priority:BuilderPriority = Normal;

  final url:String;
  
  public function new(url) {
    this.url = url;
  }

  public function apply(builder:ClassBuilder) {
    var route = url.processRoute();
    var routeParamsType = route.paramsType;
    var linkParamsType:ComplexType = switch routeParamsType {
      case TAnonymous(fields):
        TAnonymous(fields.concat((macro class {
          @:optional public final className:Null<String>;
          @:optional public final onUsed:Null<()->Void>; 
        }).fields));
      default: 
        throw 'assert';
    }
    var visitParamsType:ComplexType = switch routeParamsType {
      case TAnonymous(fields):
        TAnonymous(fields.concat((macro class {
          @:optional public final child:(goToPage:()->Void)->blok.ui.Child;
          @:optional public final onUsed:Null<()->Void>;
        }).fields));
      default: 
        throw 'assert';
    }
  
    builder.add(macro class {
      static final matcher = ${route.matcher};
  
      public static function createUrl(props:$routeParamsType):String {
        return ${route.urlBuilder};
      }
      
      public static function link(props:$linkParamsType, ...children:blok.ui.Child) {
        return blok.tower.routing.PageLink.node({
          to: createUrl(props),
          className: props.className,
          onUsed: props.onUsed,
          children: children.toArray()
        });
      }
      
      public static function visit(props:$visitParamsType) {
        return blok.tower.routing.PageVisitor.node({
          to: createUrl(props),
          onUsed: props.onUsed,
          child: props.child
        });
      }
  
      final url = new blok.signal.Signal<Null<String>>(null);
      final params = new blok.signal.Signal<Null<$routeParamsType>>(null);
      final disposables = new blok.core.DisposableCollection();
      @:noCompletion var __isDisposed:Bool = false;
  
      public function test(request:kit.http.Request):Bool {
        if (__isDisposed) return false;
        return request.method == Get && matcher.match(request.url);
      }
  
      public function match(request:kit.http.Request):kit.Maybe<blok.ui.VNode> {
        if (__isDisposed) return None;
        if (request.method != Get) return None;
        if (matcher.match(request.url)) {
          this.url.set(request.url);
          this.params.set(${route.paramsBuilder});
        
          return Some(blok.ui.Scope.wrap(context -> {
            var view = render(context);
            #if !blok.tower.client
            blok.signal.Observer.untrack(() -> {
              __exportJsonAssets(context);
            });
            #end
            return view;
          }));
        }
        return None;
      }
  
      public function dispose() {
        __isDisposed = true;
        disposables.dispose();
      }
    });
  }
}
