package blok.tower.data.macro;

import blok.macro.ClassBuilder;
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.Tools;
using blok.tower.core.macro.InjectorBuilder;
using kit.Hash;

final LoaderMeta = ':load';

typedef LoaderInfo = {
  public final dependencies:Map<String, ComplexType>;
  public final inits:Array<Expr>;
}

function processLoaders(builder:ClassBuilder, hashPrefix:Expr):LoaderInfo {
  var dependencies:Map<String, ComplexType> = [];
  var inits:Array<Expr> = [];
  var exports:Array<Expr> = [];
  var startups:Array<Expr> = [];

  for (field in builder.findFieldsByMeta(LoaderMeta)) switch field.kind {
    case FVar(t, e):
      if (t == null) {
        Context.error('Cannot infer types here', field.pos);
      }
      if (e == null) {
        Context.error('An expression is required for $LoaderMeta fields', field.pos);
      }
      if (!field.access.contains(AFinal)) {
        Context.error('$LoaderMeta fields must be final', field.pos);
      }
      if (field.access.contains(AStatic)) {
        Context.error('$LoaderMeta fields cannot be static', field.pos);
      }
      if (!Context.unify(t.toType(), (macro:blok.tower.data.JsonAware).toType())) {
        Context.error('$LoaderMeta methods must return a JsonAware type.', field.pos); 
      }

      var name = field.name;
      var hash = macro $hashPrefix + '_' + $v{name};
      var path = switch t {
        case TPath(p): 
          p.pack.concat([ p.name ]);
        default:
          // @todo: handle other possibilities here?
          Context.error('Invalid type?', field.pos);
      }

      // @todo: This is a bad idea: every time our URL updates we'll
      // trigger a new load. This is unneeded, and will break the usefulness
      // of having things like Layouts.
      //
      // We're only doing here because we're struggling to find a way to make
      // suspense work with our Capsule-based dependency injection. We
      // should find a better way to add assets.

      if (Context.defined('blok.tower.client.ssg')) {
        e = macro {
          @:inject final hydrate:blok.tower.data.Hydration;
          @:inject final api:blok.tower.remote.StaticFileClient;
          switch hydrate.extract(${hash}) {
            case Some(data): 
              $p{path}.fromJson(data);
            case None: 
              api.fetch(${hash}).next(data -> $p{path}.fromJson(data));
          }
        }
      } else if (Context.defined('blok.tower.client')) {
        e = macro {
          @:inject final hydrate:blok.tower.data.Hydration;
          switch hydrate.extract(${hash}) {
            case Some(data):
              $p{path}.fromJson(data);
            case None: 
              ${e};
          }
        }
      }

      var injectInfo = e.processInjectableScope();
      for (key => type in injectInfo.dependencies) {
        dependencies.set(key, type);
      }

      field.kind = FVar(macro:blok.suspense.Resource<$t>);
      inits.push(macro @:pos(e.pos) this.$name = blok.suspense.Resource.lazy(() -> $e));
      exports.push(macro switch this.$name.data.peek() {
        case Loaded(data):
          assets.add(new blok.tower.asset.JsonAsset({
            id: $hash,
            hydrationId: hydrationId,
            content: haxe.Json.stringify(data.toJson())
          }));
        case Error(_) | Loading:
      });
    default:
      Context.error('Invalid field type for $LoaderMeta', field.pos);
  }

  builder.add(macro class {
    #if !blok.tower.client
    function __exportJsonAssets(context:blok.ui.ComponentBase) {
      var assets = blok.tower.asset.AssetContext.from(context);
      var hydrationId = assets.hydrationId;
      @:mergeBlock $b{exports};
    }
    #end
  });

  return { dependencies: dependencies, inits: inits };
}

