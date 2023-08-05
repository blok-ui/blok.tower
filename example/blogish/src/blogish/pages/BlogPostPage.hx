package blogish.pages;

import blok.tower.content.ContentComponent;
import blogish.api.PostApi;
import blogish.data.Post;
import blok.html.Html;
import blok.tower.routing.PageRoute;
import blok.ui.*;

class BlogPostPage implements PageRoute<'/blog/post/{slug:String}'> {
  @:load final post:Post = {
    @:inject final posts:PostApi;
    posts.getPost(params().slug);
  }

  function render(context:ComponentBase) {
    return Html.article({},
      Html.header({}, 
        Html.h3({}, post().title)
      ),
      Html.div({},
        ContentComponent.node({ content: post().content })
      )
    );
  }
}
