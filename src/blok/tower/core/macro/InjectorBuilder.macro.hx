package blok.tower.core.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import blok.macro.ClassBuilder;

using haxe.macro.Tools;
using kit.Hash;

final InjectMeta = ':inject';
final InjectPrefix = "__inject__";


typedef InjectorInfo = {
  public final args:Array<FunctionArg>;
  public final inits:Array<Expr>;
}

function processInjectFields(builder:ClassBuilder):InjectorInfo {
  var info:InjectorInfo = {
    args: [],
    inits: []
  };

  for (field in builder.findFieldsByMeta(InjectMeta)) switch field.kind {
    case FVar(t, e):
      if (t == null) {
        Context.error('Cannot infer types for $InjectMeta fields', field.pos);
      }
      if (e != null) {
        Context.error('$InjectMeta fields cannot have an expression', e.pos);
      }

      var name = field.name;
      info.args.push({ name: name, type: t });
      info.inits.push(macro this.$name = $i{name});
    default:
      Context.error('Invalid field type for $InjectMeta', field.pos);
  }

  return info;
}

typedef InjectorExprInfo = {
  public final dependencies:Map<String, ComplexType>;
  public final fields:Array<Field>;
} 

function processInjectableScope(expr:Expr):InjectorExprInfo {
  var info:InjectorExprInfo = {
    dependencies: [],
    fields: []
  };

  function process(e:Expr) {
    switch e.expr {
      case EMeta(entry, e) if (entry.name == InjectMeta): switch e {
        case (macro var $name:$t) | (macro final $name:$t):
          var fieldName = InjectPrefix + t.toString().hash();
          info.dependencies.set(fieldName, t);
          info.fields.push({
            name: fieldName,
            kind: FVar(t),
            access: [ AFinal ],
            pos: (macro null).pos
          });
          e.expr = EVars([
            { name: name, type: t, expr: macro this.$fieldName }
          ]);
        default:
          Context.error('$InjectMeta fields must be used on vars', e.pos);
      }
      default: e.iter(process); 
    }
  }

  expr.iter(process);
  
  return info;
}

