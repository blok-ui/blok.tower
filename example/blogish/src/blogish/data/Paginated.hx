package blogish.data;

import blok.tower.data.JsonAware;

class Paginated implements JsonAware {
  @:constant public final page:Int;
  @:constant public final perPage:Int;
  @:json(
    to = value.map(post -> post.toJson()),
    from = value.map(Post.fromJson)
  )
  @:constant 
  public final items:Array<Post>;
}
