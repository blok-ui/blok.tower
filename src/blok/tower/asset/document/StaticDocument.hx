package blok.tower.asset.document;

import blok.html.server.*;

using Lambda;
using Reflect;

class StaticDocument extends Document {
  final head = new Element('head', {});
  final body = new Element('body', {});

  public function getHead():Dynamic {
    return head;
  }

  public function getBody():Dynamic {
    return body;
  }

  public function getLayer(id:String):Dynamic {
    var layer = body.children.find(obj -> obj.field('attributes').field('id') == id);
    if (layer == null) {
      layer = new Element('div', { id: id });
      body.prepend(layer);
    }
    return layer;
  }

  public function toString() {
    return '<!doctype html>
<html>
  ${head.toString()}
  ${body.toString()}
</html>';
  }

  public function setTitle(title:String):Void {
    var el:Element = cast head.children.find(child -> switch Std.downcast(child, Element) {
      case null: false;
      case obj: obj.tag == 'title';
    });
    if (el == null) {
      el = new Element('title', {});
      el.append(new TextNode(title, false));
      head.append(el);
    } else {
      el.children = [];
      el.append(new TextNode(title, false));
    }
  }

  public function setMeta(key:String, value:String):Void {
    switch key {
      case 'charset':
        var el:Element = cast head.children.find(child -> switch Std.downcast(child, Element) {
          case null: false;
          case obj: obj.tag == 'meta' && obj.attributes.hasField('charset');
        });
        if (el == null) {
          el = new Element('meta', {
            charset: value
          });
          head.append(el);
        } else {
          el.setAttribute('charset', value);
        }
      default:
        var el:Element = cast head.children.find(child -> switch Std.downcast(child, Element) {
          case null: false;
          case obj: obj.tag == 'meta' && obj.attributes.field('name') == key;
        });
        if (el == null) {
          el = new Element('meta', {
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
