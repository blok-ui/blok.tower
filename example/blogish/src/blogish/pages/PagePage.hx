package blogish.pages;

import blogish.api.PageApi;
import blogish.data.Post;
import blogish.ui.page.*;
import blok.tower.routing.PageRoute;
import blok.ui.*;

class PagePage implements PageRoute<'page/{slug:String}'> {
  @:load final page:Post = {
    @:inject final pages:PageApi;
    pages.getPage(params().slug);
  }

  function render(context:View) {
    return Fragment.node(
      PageHeader.node({ title: page().title }),
      PageContent.node({
        children: page().content.render()
      })
    );
  }
}
