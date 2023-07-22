package blok.tower.routing;

import blok.html.Html;
import blok.ui.*;

class PageLink extends Component {
  @:constant final to:String;
  @:constant final onUsed:()->Void = null;
  @:observable final className:String = null;
  @:constant final children:Children;
  
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
