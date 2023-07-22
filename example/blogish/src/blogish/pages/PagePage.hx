package blogish.pages;

import blogish.data.Post;
import blogish.api.PageApi;
import blok.ui.*;
import blok.html.Html;
import blok.tower.routing.PageRoute;

class PagePage implements PageRoute<'page/{slug:String}'> {
  @:inject final pages:PageApi;
  @:load final page:Post = pages.getPage(params().slug);

  function render(context:ComponentBase) {
    return Html.div({}, page().title);
  }
}
