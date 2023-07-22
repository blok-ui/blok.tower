package blok.tower.data;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import blok.macro.ClassBuilder;

using Lambda;
using haxe.macro.Tools;
using blok.macro.MacroTools;

// @todo: Only parse @:constant, @:signal and @:observable fields.
function build() {
  var fields = Context.getBuildFields();
  var builder = new ClassBuilder(fields);
  var serialize:Array<ObjectField> = [];
  var unserialize:Array<ObjectField> = [];

  for (field in fields) switch field.kind {
    case FVar(t, e):
      var meta = field.meta.find(f -> f.name == ':json');
      var name = field.name;
      var def = e == null ? macro null : e;

      field.meta.remove(meta);

      if (meta != null) switch meta.params {
        case [ macro to = ${to}, macro from = ${from} ] | [ macro from = ${from}, macro to = ${to} ]:
          serialize.push({
            field: name,
            expr: macro {
              var value = this.$name;
              if (value == null) null else $to;
            }
          });
          switch t {
            case macro:Array<$_>:
              unserialize.push({
                field: name,
                expr: macro {
                  var value:Array<Dynamic> = Reflect.field(data, $v{name});
                  if (value == null) value = [];
                  $from;
                }
              });
            default:
              unserialize.push({
                field: name,
                expr: macro {
                  var value:Dynamic = Reflect.field(data, $v{name});
                  if (value == null) $def else ${from};
                }
              });
          }
        case []:
          Context.warning('There is no need to mark fields with @:json unless you are defining how they should serialize/unserialize', meta.pos);
        default:
          Context.error('Invalid arguments', meta.pos);
      } else switch t {
        case macro:Null<$t> if (isJsonAware(t)):
          var path = switch t {
            case TPath(p): p.pack.concat([ p.name ]);
            default: Context.error('Could not resolve type', field.pos);
          }
          serialize.push({
            field: name,
            expr: macro this.$name?.toJson()
          });
          unserialize.push({
            field: name,
            expr: macro {
              var value:Dynamic = Reflect.field(data, $v{name});
              if (value == null) null else  $p{path}.fromJson(value);
            }
          });
        case macro:Array<$t> if (isJsonAware(t)):
          var path = switch t {
            case TPath(p): p.pack.concat([ p.name ]);
            default: Context.error('Could not resolve type', field.pos);
          }
          serialize.push({
            field: name,
            expr: macro this.$name.map(item -> item.toJson())
          });
          unserialize.push({
            field: name,
            expr: macro {
              var values:Array<Dynamic> = Reflect.field(data, $v{name});
              values.map($p{path}.fromJson);
            }
          });
        case t if (isJsonAware(t)):
          var path = switch t {
            case TPath(p): p.pack.concat([ p.name ]);
            default: Context.error('Could not resolve type', field.pos);
          }
          serialize.push({
            field: name,
            expr: macro this.$name?.toJson()
          });
          unserialize.push({
            field: name,
            expr: macro {
              var value:Dynamic = Reflect.field(data, $v{name});
              $p{path}.fromJson(value);
            }
          });
        default:
          serialize.push({
            field: name,
            expr: macro this.$name
          });
          unserialize.push({
            field: name,
            expr: macro Reflect.field(data, $v{name})
          });
      }
    default:
  }

  var cls = Context.getLocalClass().get();
  var pos = cls.pos;
  var clsType = Context.getLocalType().toComplexType();
  var clsTp:TypePath = { pack: cls.pack, name: cls.name };
  var params = cls.params.length > 0
    ? [ for (p in cls.params) { name: p.name, constraints: extractTypeParams(p) } ]
    : [];

  builder.addField({
    name: 'fromJson',
    access: [ AStatic, APublic ],
    pos: pos,
    meta: [],
    kind: FFun({
      params: params,
      args: [
        { name: 'data', type: macro:Dynamic }
      ],
      expr: macro return new $clsTp(${ {
        expr: EObjectDecl(unserialize),
        pos: pos
      } }),
      ret: macro:$clsType
    })
  });

  builder.add(macro class {
    public function toJson():Dynamic {
      return ${ {
        expr: EObjectDecl(serialize),
        pos: pos
      } };
    }
  });

  return builder.export();
}

function getPathExprFromType(t:Type):Expr {
  var clsName = t.toString();
  if (clsName.indexOf('<') >= 0) clsName = clsName.substring(0, clsName.indexOf('<'));
  var path = clsName.split('.');
  return macro $p{path};
}

function extractTypeParams(tp:TypeParameter) {
  return switch tp.t {
    case TInst(kind, _): switch kind.get().kind {
      case KTypeParameter(constraints): constraints.map(t -> t.toComplexType());
      default: [];
    }
    default: [];
  }
}

function isJsonAware(t:ComplexType) {
  return Context.unify(t.toType(), (macro:blok.tower.data.JsonAware).toType());
}
