package blogish.pages;

import blogish.api.PostApi;
import blogish.data.*;
import blogish.ui.page.*;
import blok.html.Html;
import blok.tower.routing.PageRoute;
import blok.ui.View;

class BlogPostArchivePage implements PageRoute<'/blog/archive/page-{page:Int}'> {
  @:load final posts:Paginated = {
    @:inject final postApi:PostApi;
    postApi.paginatePosts(params().page);
  }

  function render(_:View) {
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
