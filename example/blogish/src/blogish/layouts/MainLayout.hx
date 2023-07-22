package blogish.layouts;

import blogish.api.SiteApi;
import blogish.data.Site;
import blogish.ui.site.SiteHeader;
import blok.html.Html;
import blok.suspense.SuspenseBoundary;
import blok.tower.routing.LayoutRoute;
import blok.ui.*;

class MainLayout implements LayoutRoute<'blogish.pages'> {
  @:load final site:Site = {
    @:inject final siteApi:SiteApi;
    siteApi.get();
  }

  function render(context:ComponentBase, router:Child) {
    return Html.div({},
      SiteHeader.node({ site: site() }),
      Html.main({}, SuspenseBoundary.node({
        child: router,
        fallback: () -> 'Loading...'
      }))
    );
  }
}
