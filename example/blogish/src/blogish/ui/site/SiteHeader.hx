package blogish.ui.site;

import blogish.data.Site;
import blogish.pages.HomePage;
import blok.html.Html;
import blok.tower.routing.PageVisitor;
import blok.ui.*;

class SiteHeader extends Component {
  @:constant final site:Site;

  function render() {
    return Html.header({},
      Html.div({},
        Html.div({}, HomePage.link({}, 
          Html.h1({}, site.title).styles(
            Typography.fontSize('xxl'),
            Typography.fontWeight('bold')
          )
        )).styles(Spacing.margin('right', 'auto')),

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
          ]).horizontalLayout()
        )
      ).horizontalLayout()
        .centerAlign()
        .constrainWidthToContainer()
        .styles(Spacing.pad(3))

    ).styles(
      Background.color('black', 0),
      Typography.textColor('white', 0)
    );
  }
}
