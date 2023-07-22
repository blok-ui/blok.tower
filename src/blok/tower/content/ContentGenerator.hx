package blok.tower.content;

import haxe.DynamicAccess;

using Reflect;
using StringTools;

function toContent(html:String) {
  var xml = Xml.parse(html);
  return parseNode(xml);
}

private function parseNode(node:Xml):Content {
  return switch node.nodeType {
    case Element if (node.nodeName == 'script'):
      null;
    case PCData if (node.nodeValue == '\n' || node.nodeValue.trim() == ''): 
      null;
    case PCData:
      new Content({
        type: ContentType.Text,
        data: node.nodeValue
      });
    case Element:
      var attrs:DynamicAccess<Dynamic> = {};
      for (p in node.attributes()) attrs[p] = node.get(p);
      new Content ({
        type: node.nodeName,
        data: attrs,
        children: parseChildren(node)
      });
    case Document:
      new Content({
        type: ContentType.Fragment,
        data: null,
        children: parseChildren(node)
      });
    default:
      return null;
  }
}

private function parseChildren(nodes:Xml) {
  return [ for (child in nodes) parseNode(child) ].filter(n -> n != null);
}
