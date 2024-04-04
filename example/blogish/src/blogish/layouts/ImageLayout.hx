package blogish.layouts;

import blogish.api.SiteApi;
import blogish.data.Site;
import blogish.pages.HomePage;
import blogish.ui.site.SiteHead;
import blok.html.Html;
import blok.tower.routing.LayoutRoute;
import blok.ui.*;

class ImageLayout implements LayoutRoute<'blogish.pages.images'> {
  @:load final site:Site = {
    @:inject final siteApi:SiteApi;
    siteApi.get();
  }

  function render(context:View, router:Child):Child {
    return Fragment.node(
      SiteHead.node({ site: site() }),
      Html.div({}, 
        Html.header({},
          HomePage.link({}, 
            Html.h2({}, '<- Return home').styles(
              Typography.fontSize('lg'),
              Typography.fontWeight('bold')
            )
          ),
        ).styles(
          Spacing.margin('bottom', 3)
        ),
        Html.div({}, router)
      ).constrainWidthToContainer(),
    );
  }
}
