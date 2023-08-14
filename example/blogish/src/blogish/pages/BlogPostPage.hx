package blogish.pages;

import blogish.api.PostApi;
import blogish.data.Post;
import blogish.ui.page.*;
import blok.tower.routing.PageRoute;
import blok.ui.*;

class BlogPostPage implements PageRoute<'/blog/post/{slug:String}'> {
  @:load final post:Post = {
    @:inject final posts:PostApi;
    posts.getPost(params().slug);
  }

  function render(context:ComponentBase) {
    return Fragment.node(
      PageHeader.node({ title: post().title }),
      PageContent.node({
        children: post().content.render()
      })
    );
  }
}
