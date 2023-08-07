package blogish.layouts;

import blogish.api.SiteApi;
import blogish.data.Site;
import blogish.ui.placeholder.ErrorHandler;
import blogish.ui.site.SiteHead;
import blogish.ui.site.SiteHeader;
import blok.html.Html;
import blok.suspense.SuspenseBoundary;
import blok.tower.routing.LayoutRoute;
import blok.ui.*;

using blok.boundary.BoundaryModifiers;

class MainLayout implements LayoutRoute<'blogish.pages'> {
  @:load final site:Site = {
    @:inject final siteApi:SiteApi;
    siteApi.get();
  }

  function render(context:ComponentBase, router:Child) {
    return Html.main({}, 
      SiteHead.node({ site: site() }),
      SiteHeader.node({ site: site() }),
      SuspenseBoundary.node({
        child: router,
        fallback: () -> Html.div({}, 'Loading...').styles(
          Background.color('gray', 200),
          Spacing.pad(3)
        )
      })
    ).inErrorBoundary((_, e) -> ErrorHandler.node({ error: e }));
  }
}
