package blogish.pages;

import blogish.data.*;
import blok.ui.ComponentBase;
import blogish.api.PostApi;
import blok.tower.routing.PageRoute;

class BlogPostArchivePage implements PageRoute<'/blog/archive/page-{page:Int}'> {
  @:inject final postApi:PostApi;

  @:load final posts:Paginated = postApi.paginatePosts(params().page);

  function render(_:ComponentBase) {
    return null;
  }
}
