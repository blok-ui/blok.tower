package blogish.ui.site;

import blogish.pages.HomePage;
import blok.tower.routing.PageVisitor;
import blogish.data.Site;
import blok.html.Html;
import blok.ui.*;

class SiteHeader extends Component {
  @:constant final site:Site;

  function render() {
    return Html.header({},
      Html.div({}, HomePage.link({}, 
        Html.h1({}, site.title).styles(
          Typography.fontSize('xxl'),
          Typography.fontWeight('bold')
        )
      )).styles(
        Spacing.margin('right', 'auto')
      ),
      Html.nav({}, 
        Html.ul({}, ...[ for (option in site.menu.options) 
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
        ]).styles(
          Flex.display(),
          Flex.gap(3)
        )
      )
    ).styles(
      Flex.display(),
      Flex.alignItems('center'),
      Flex.gap(3),
      Spacing.pad(3),
      Background.color('black', 0),
      Typography.textColor('white', 0)
    );
  }
}
