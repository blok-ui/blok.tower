package blok.tower.content;

import blok.context.Context;
import blok.core.BlokException;
import blok.html.TagCollection;
import blok.signal.Signal;
import blok.tower.core.AppContext;
import blok.tower.routing.PageLink;
import blok.ui.*;

@:fallback(AppContext.from(context).container.get(ContentContext))
class ContentContext implements Context {
  final factory:ContentFactory;

  public function new(factory) {
    this.factory = factory;
  }

  public function render(content:Content):Child {
    return switch content.type {
      case ContentType.Fragment:
        Fragment.node(...content.children.map(render));
      case ContentType.RouteLink:
        return PageLink.node({
          to: content.data.url,
          className: content.data.className,
          children: content.children.map(render)
        });
      case ContentType.Text:
        var str:String = content.data ?? '';
        Text.node(str);
      default:
        if (factory.has(content)) {
          return factory.create(content, render);
        }
        
        if (allowedHtmlTags.contains(content.type)) {
          var type = getTypeForTag(content.type);
          var props:{} = {};
          for (field in Reflect.fields(content.data)) {
            Reflect.setField(props, field, new ReadOnlySignal(Reflect.field(content.data, field)));
          }
          return new VPrimitive(type, content.type, props, content.children.map(render));
        }

        throw new BlokException(
          'Cannot render content of the type [${content.type}].'
          #if debug
          + ' Check your registered modules and make sure you have a ContentFactory'
          + ' that can handle this type.'
          #end
        );
    }
  }

  public function dispose() {
    // noop
  }
}

private final allowedHtmlTags = [
  'div',
  'code',
  'aside',
  'article',
  'blockquote',
  'section',
  'header',
  'footer',
  'main',
  'nav',
  'table',
  'thead',
  'tbody',
  'tfoot',
  'tr',
  'td',
  'th',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'strong',
  'em',
  'span',
  'a',
  'p',
  'ins',
  'del',
  'i',
  'b',
  'small',
  'menu',
  'ul',
  'ol',
  'li',
  'label',
  'button',
  'pre',
  'picture',
  'canvas',
  'audio',
  'video',
  'form',
  'fieldset',
  'legend',
  'select',
  'option',
  'dl',
  'dt',
  'dd',
  'details',
  'summary',
  'figure',
  'figcaption',
  'textarea',
  'br',
  'embed',
  'hr',
  'img',
  'input',
  'link',
  'meta',
  'param',
  'source',
  'track',
  'wbr',
];
