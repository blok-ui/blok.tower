package blok.tower.macro.builder;

import blok.macro.*;
import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;
using blok.macro.MacroTools;
using haxe.macro.Tools;
using kit.Hash;

typedef InjectFieldBuilderOptions = {
  public final buildConstructor:Bool;
  public final ?customBuilder:(options:{
    builder:ClassBuilder,
    args:Array<FunctionArg>,
    previousExpr:Maybe<Expr>,
    inits:Expr,
    lateInits:Expr
  })->Function;
}

class InjectFieldBuilder implements Builder {
  static inline final injectPrefix = "__inject__";

  public final priority:BuilderPriority = Late;
  
  final options:InjectFieldBuilderOptions;

  public function new(options) {
    this.options = options;
  }

  public function apply(builder:ClassBuilder) {
    for (field in builder.findFieldsByMeta(':inject')) {
      applyInjectField(builder, field);
    }
    
    for (expr in builder.getHook('init')) {
      processInitExpr(builder, expr);
    }

    for (expr in builder.getHook('init:late')) {
      processInitExpr(builder, expr);
    }

    if (options.buildConstructor) {
      buildConstructor(builder);
    }
  }

  function buildConstructor(builder:ClassBuilder) {
    var currentConstructor = builder.findField('new');
    var previousExpr:Maybe<Expr> = switch currentConstructor {
      case Some(field): switch field.kind {
        case FFun(f):
          if (f.args.length > 0) {
            Context.error(
              'You cannot pass arguments to this constructor -- it can only '
              + 'be used to run code at initialization.',
              field.pos
            );
          }
          Some(f.expr);
        default: 
          throw 'assert';
      }
      case None:
        None;
    }
    var args:Array<FunctionArg> = builder.getProps('inject').map(f -> ({
      name: f.name,
      type: switch f.kind {
        case FVar(t, _): t;
        default: throw 'assert';
      }
    }:FunctionArg));
    var init = builder.getHook('init:inject').concat(builder.getHook('init'));
    var late = builder.getHook('init:late');
    var func:Function = switch options.customBuilder {
      case null:
        var expr:Expr = macro {
          @:mergeBlock $b{init};
          @:mergeBlock $b{late};
          ${switch previousExpr {
            case Some(expr): expr;
            case None: macro null;
          }}
        }
        {
          args: args,
          expr: expr
        }
      case custom:
        custom({
          builder: builder,
          args: args,
          inits: macro @:mergeBlock $b{init},
          lateInits: macro @:mergeBlock $b{late},
          previousExpr: previousExpr
        });
    }

    switch currentConstructor {
      case Some(field):
        field.kind = FFun(func);
      case None:
        builder.addField({
          name: 'new',
          access: [ APublic ],
          kind: FFun(func),
          pos: (macro null).pos
        });
    }
  }

  function applyInjectField(builder:ClassBuilder, field:Field) {
    switch field.kind {
      case FVar(t, e):
        if (t == null) {
          Context.error('Cannot infer types for :inject fields', field.pos);
        }
        if (e != null) {
          Context.error(':inject fields cannot have an expression', e.pos);
        }
        var name = field.name;
        addInjectField(builder, name, t);
        builder.addHook('init:inject', macro this.$name = $i{name});
      default:
        Context.error('Invalid field type for :inject', field.pos);
    }
  }

  function processInitExpr(builder:ClassBuilder, e:Expr) {
    function process(e:Expr) {
      switch e.expr {
        case EMeta(entry, e) if (entry.name == ':inject'): switch e {
          case (macro var $name:$t) | (macro final $name:$t):
            var injectedName = injectPrefix + t.toString().hash();
            e.expr = EVars([
              { name: name, type: t, expr: macro $i{injectedName} }
            ]);
            addInjectField(builder, injectedName, t);
          default:
            Context.error(':inject meta must be used on vars', e.pos);
        }
        default: e.iter(process); 
      }
    }
    e.iter(process);
  }

  function addInjectField(builder:ClassBuilder, name:String, t:ComplexType) {
    if (builder.getProps('inject').exists(f -> f.name == name)) return;
    builder.addProp('inject', {
      name: name,
      type: t,
      optional: false
    });
  }
}
