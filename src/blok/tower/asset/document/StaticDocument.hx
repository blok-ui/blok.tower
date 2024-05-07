package blok.tower.asset.document;

import blok.html.server.*;

using Lambda;
using Reflect;

class StaticDocument extends Document {
  final head = new ElementPrimitive('head', {});
  final body = new ElementPrimitive('body', {});

  public function getHead():Dynamic {
    return head;
  }

  public function getBody():Dynamic {
    return body;
  }

  public function getLayer(id:String):Dynamic {
    var layer = body.children.find(obj -> obj.field('attributes').field('id') == id);
    if (layer == null) {
      layer = new ElementPrimitive('div', { id: id });
      body.prepend(layer);
    }
    return layer;
  }

  public function toString() {
    return '<!doctype html>
<html>
  ${head.toString({ includeTextMarkers: false })}
  ${body.toString()}
</html>';
  }

  public function setTitle(title:String):Void {
    var el:ElementPrimitive = cast head.children.find(child -> switch Std.downcast(child, ElementPrimitive) {
      case null: false;
      case obj: obj.tag == 'title';
    });
    if (el == null) {
      el = new ElementPrimitive('title', {});
      el.append(new TextPrimitive(title));
      head.append(el);
    } else {
      el.children = [];
      el.append(new TextPrimitive(title));
    }
  }

  public function setMeta(key:String, value:String):Void {
    switch key {
      case 'charset':
        var el:ElementPrimitive = cast head.children.find(child -> switch Std.downcast(child, ElementPrimitive) {
          case null: false;
          case obj: obj.tag == 'meta' && obj.attributes.hasField('charset');
        });
        if (el == null) {
          el = new ElementPrimitive('meta', {
            charset: value
          });
          head.append(el);
        } else {
          el.setAttribute('charset', value);
        }
      default:
        var el:ElementPrimitive = cast head.children.find(child -> switch Std.downcast(child, ElementPrimitive) {
          case null: false;
          case obj: obj.tag == 'meta' && obj.attributes.field('name') == key;
        });
        if (el == null) {
          el = new ElementPrimitive('meta', {
            name: key,
            content: value
          });
          head.append(el);
        } else {
          el.setAttribute('name', key);
          el.setAttribute('content', value);
        }
    }
  }
}
