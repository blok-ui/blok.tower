package blogish.ui.site;

import blok.tower.routing.PageVisitor;
import blogish.data.Site;
import blok.html.Html;
import blok.ui.*;

class SiteHeader extends Component {
  @:constant final site:Site;

  function render() {
    return Html.header({},
      Html.div({}, Html.h1({}, site.title)),
      Html.nav({}, Html.ul({}, ...[ for (option in site.menu.options) 
        Html.li({}, switch option.type {
          case ExternalLink: Placeholder.node();
          case InternalLink: PageVisitor.node({
            to: option.url,
            child: goToPage -> Html.a({
              href: option.url,
              onClick: e -> {
                e.preventDefault();
                goToPage();
              }
            }, option.label)
          });
        })
      ]))
    );
  }
}
