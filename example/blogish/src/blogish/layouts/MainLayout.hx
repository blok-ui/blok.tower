package blogish.layouts;

import blogish.api.SiteApi;
import blogish.data.Site;
import blogish.ui.placeholder.ErrorHandler;
import blogish.ui.site.SiteHeader;
import blok.html.Html;
import blok.suspense.SuspenseBoundary;
import blok.tower.routing.LayoutRoute;
import blok.tower.ui.*;
import blok.ui.*;
import haxe.macro.Compiler;

using blok.boundary.BoundaryModifiers;
using haxe.io.Path;


class MainLayout implements LayoutRoute<'blogish.pages'> {
  @:load final site:Site = {
    @:inject final siteApi:SiteApi;
    siteApi.get();
  }

  function render(context:ComponentBase, router:Child) {
    var stylesPath = Compiler.getDefine('breeze.output')?.withExtension('css') ?? 'styles.css'; 
    return Fragment.node(
      Head.node({
        children: [
          Html.title({}, site().title),
          Html.meta({ name: 'viewport', content: 'width=device-width, initial-scale=1' }),
          Style.node({ src: stylesPath, kind: Generated })
        ]
      }),
      SiteHeader.node({ site: site() }),
      Html.main({}, SuspenseBoundary.node({
        child: router,
        fallback: () -> Html.div({}, 'Loading...').styles(
          Background.color('gray', 200),
          Spacing.pad(3)
        )
      })).constrainWidthToContainer()
        .styles(Spacing.margin('top', 3))
    ).inErrorBoundary((_, e) -> ErrorHandler.node({ error: e }));
  }
}
