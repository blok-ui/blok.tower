package blogish.pages;

import blogish.ui.page.*;
import blok.html.Html;
import blogish.data.*;
import blok.ui.ComponentBase;
import blogish.api.PostApi;
import blok.tower.routing.PageRoute;

class BlogPostArchivePage implements PageRoute<'/blog/archive/page-{page:Int}'> {
  @:load final posts:Paginated = {
    @:inject final postApi:PostApi;
    postApi.paginatePosts(params().page);
  }

  function render(_:ComponentBase) {
    return Fragment.node(
      PageHeader.node({ title: 'Blog Posts' }),
      PageContent.node({
        children: Html.ul({}, ...[for (post in posts().items)
          Html.li({}, BlogPostPage.link({ slug: post.slug }, post.title))
        ])
      })
    );
  }
}
