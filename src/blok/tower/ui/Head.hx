package blok.tower.ui;

import blok.tower.core.SemVer;
import blok.core.BlokException.BlokComponentException;
import blok.html.server.*;
import blok.tower.asset.*;
import blok.ui.*;

using Reflect;
using StringTools;

class Head extends Component {
  @:constant final children:Children;

  function setup() {
    var root = RootComponent.node({
      target: new Element('head', {}),
      child: () -> Fragment.node(...children.toArray()),
      adaptor: new ServerAdaptor({ prefixTextWithMarker: false })
    });
    var component = root.createComponent();
    component.mount(this, null);

    updateRealHead(this, component, children);

    addDisposable(component);
  }

  function render() {
    return Placeholder.node();
  }
}

private function updateRealHead(
  head:ComponentBase,
  root:ComponentBase,
  children:Array<VNode>
) {
  var assets = AssetContext.from(head);
  var document = AssetContext.from(head).document;
  var target:Element = root.getRealNode();
  
  for (child in target.children) switch Std.downcast(child, Element) {
    case null:
    case el: switch el.tag {
      case 'title':
        var content = el.children.map(d -> d.toString()).join('');
        document.setTitle(content);
      case 'meta' if (el.attributes.hasField('charset')):
        document.setMeta('charset', el.attributes.field('charset'));
      case 'meta' if (el.attributes.hasField('name')):
        document.setMeta(
          el.attributes.field('name'),
          el.attributes.field('content')
        );
      case 'link' if (el.attributes.field('rel') == 'stylesheet'):
        var ver:Null<String> = el.attributes.field('data-sem-ver');
        assets.add(new CssAsset(
          el.attributes.field('href'),
          if (el.attributes.field('data-source') != null) 
            Local(el.attributes.field('data-source'))
          else if (el.attributes.field('data-generated') != null)
            Generated
          else 
            External,
          if (ver != null) SemVer.parse(ver) else null
        ));
      case 'script':
        var ver:Null<String> = el.attributes.field('data-sem-ver');
        assets.add(new JsAsset(
          el.attributes.field('src'),
          if (el.attributes.field('data-source') != null) 
            Local(el.attributes.field('data-source'))
          else if (el.attributes.field('data-generated') != null)
            Generated
          else if (el.attributes.field('data-inline') != null)
            Inline(el.attributes.field('data-inline'))
          else 
            External,
          if (ver != null) SemVer.parse(ver) else null
        ));
      case other:
        throw new BlokComponentException('Couldn\'t handle ' + other + ' tag.', head);
    }
  }
}
