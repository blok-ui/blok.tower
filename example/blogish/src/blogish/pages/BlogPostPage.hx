package blogish.pages;

import blogish.api.PostApi;
import blogish.data.Post;
import blok.html.Html;
import blok.tower.data.JsonAware;
import blok.tower.routing.PageRoute;
import blok.ui.*;

class BlogPostPage implements PageRoute<'/blog/post/{slug:String}'> {
  @:load final post:Post = {
    @:inject final posts:PostApi;
    posts.getPost(params().slug);
  }

  function render(context:ComponentBase) {
    return Html.div({},
      post().title
    );
  }
}
