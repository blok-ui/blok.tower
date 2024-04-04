package blok.tower.macro.builder;

import blok.macro.*;
import blok.tower.macro.CompileConfig;
import haxe.macro.Context;
import haxe.macro.Expr;

using blok.macro.MacroTools;
using haxe.macro.Tools;

typedef LoadFieldBuilderOptions = {
  public final createHashPrefix:(builder:ClassBuilder)->Expr;
  public final createJsonAssetExportMethod:Bool;
} 

class LoadFieldBuilder implements Builder {
  public final priority:BuilderPriority = Normal;

  final options:LoadFieldBuilderOptions;

  public function new(options) {
    this.options = options;
  }

  public function apply(builder:ClassBuilder) {
    for (field in builder.findFieldsByMeta(':load')) {
      applyLoadField(builder, field);
    }
    if (options.createJsonAssetExportMethod) {
      var exports = builder.getHook('load:export-json-assets');
      builder.add(macro class {
        #if !blok.tower.client
        function __exportJsonAssets(context:blok.ui.View) {
          var assets = blok.tower.asset.AssetContext.from(context);
          @:mergeBlock $b{exports};
        }
        #end
      });
    }
  }

  function applyLoadField(builder:ClassBuilder, field:Field) {
    var hashPrefix = options.createHashPrefix(builder);

    switch field.kind {
      case FVar(t, e):
        if (t == null) {
          Context.error('Cannot infer types here', field.pos);
        }
        if (e == null) {
          Context.error('An expression is required for :load fields', field.pos);
        }
        if (!field.access.contains(AFinal)) {
          Context.error(':load fields must be final', field.pos);
        }
        if (field.access.contains(AStatic)) {
          Context.error(':load fields cannot be static', field.pos);
        }
        if (!Context.unify(t.toType(), (macro:blok.data.Model).toType())) {
          Context.error(':load methods must return a Model type.', field.pos); 
        }

        var name = field.name;
        var hash = macro $hashPrefix + '_' + $v{name};
        var path = switch t {
          case TPath(p):
            p.typePathToArray();
          default:
            // @todo: handle other possibilities here?
            Context.error('Invalid type?', field.pos);
        }

        if (isClient() && getAppType() == StaticApp) {
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
        } else if (isClient()) {
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

        field.kind = FVar(macro:blok.suspense.Resource<$t>);
        builder.addHook('init:late', macro @:pos(e.pos) this.$name = new blok.suspense.Resource(() -> $e));
        builder.addHook('load:export-json-assets', macro switch this.$name.data.peek() {
          case Loaded(data):
            assets.add(new blok.tower.asset.JsonAsset({
              id: $hash,
              content: haxe.Json.stringify(data.toJson())
            }));
          case Error(_) | Loading(_) | Pending:
        });
      default:
        Context.error('Invalid field type for :load', field.pos);
    }
  }
}
