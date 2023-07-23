package blok.tower.routing;

import blok.macro.ClassBuilder;
import haxe.macro.Context;
import haxe.macro.Expr;

using blok.macro.MacroTools;
using blok.tower.core.macro.InjectorBuilder;
using blok.tower.data.macro.LoaderBuilder;
using blok.tower.routing.macro.RouteBuilder;
using kit.Hash;

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, [ TInst(_.get() => {kind: KExpr(macro $v{(url:String)})}, _) ]):
      buildPageRoute(url.normalizeUrl());
    default:
      throw 'assert';
  }
}

function build(url:String) {
  var builder = ClassBuilder.fromContext();
  var loaderInfo = builder.processLoaders(macro kit.Hash.hash(url.get()));
  var injectInfo = builder.processInjectFields();
  var args = [ for (name => type in loaderInfo.dependencies) {
    name: name,
    type: type,
  } ].concat(injectInfo.args);
  
  for (name => type in loaderInfo.dependencies) {
    builder.add(macro class {
      final $name:$type;
    });
  }

  // @todo: The way our resources work right now means that we'll
  // only re-load a resource if a dependency (like `params()`) changes.
  // It honestly might be better to do a fetch every time our page loads.
  // This might just mean we have some kind of `refresh` method on our
  // `Resource` class? We'll have to see how big of a problem this is.
  //
  // Right now, it's sort of a weird, unpredictable cache.

  builder.addField({
    name: 'new',
    access: [ APublic ],
    kind: FFun({
      args: args,
      expr: macro {
        @:mergeBlock $b{ [ for (name => _ in loaderInfo.dependencies) macro this.$name = $i{name} ] };
        @:mergeBlock $b{injectInfo.inits};
        @:mergeBlock $b{loaderInfo.inits};
      }
    }),
    pos: (macro null).pos
  });
  
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

    public function test(request:kit.http.Request):Bool {
      return request.method == Get && matcher.match(request.url);
    }

    public function match(request:kit.http.Request):kit.Maybe<blok.ui.VNode> {
      if (request.method != Get) return None;
      if (matcher.match(request.url)) {
        blok.signal.Action.run(() -> {
          this.url.set(request.url);
          this.params.set(${route.paramsBuilder});
        });
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
  });

  return builder.export();
}

function buildPageRoute(url:String) {
  var suffix = url.hash();
  var pos = Context.getLocalClass().get().pos;
  var pack = [ 'blok', 'tower', 'routing' ];
  var name = 'PageRoute_${suffix}';
  var path:TypePath = { pack: pack, name: name, params: [] };

  if (path.typePathExists()) return TPath(path);

  var builder = new ClassBuilder([]);

  builder.add(macro class {
    private function render(context:blok.ui.ComponentBase):blok.ui.Child;
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
