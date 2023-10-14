package blok.tower.routing;

import blok.html.Html;
import blok.ui.*;

class PageLink extends Component {
  @:attribute final to:String;
  @:attribute final onUsed:()->Void = null;
  @:observable final className:String = null;
  @:attribute final children:Children;
  
  function render() {
    return PageVisitor.node({
      to: to,
      onUsed: onUsed,
      child: goToPage -> Html.a({
        className: className,
        href: to,
        onClick: e -> {
          e.preventDefault();
          goToPage();
        }
      }, ...children.toArray())
    });
  }
}
