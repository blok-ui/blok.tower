package blogish.layouts;

import blogish.api.SiteApi;
import blok.suspense.SuspenseBoundary;
import blok.html.Html;
import blok.tower.routing.LayoutRoute;
import blok.ui.*;
import blogish.data.Site;

class MainLayout implements LayoutRoute<'blogish.pages'> {
  @:load final site:Site = {
    @:inject final siteApi:SiteApi;
    siteApi.get();
  }

  function render(context:ComponentBase, router:Child) {
    return Html.div({},
      Html.header({}, Html.h1({}, site().title)),
      Html.main({}, SuspenseBoundary.node({
        child: router,
        fallback: () -> 'Loading...'
      }))
    );
  }
}
