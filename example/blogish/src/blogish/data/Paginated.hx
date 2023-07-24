package blogish.data;

import blok.data.Model;

class Paginated extends Model {
  @:constant public final page:Int;
  @:constant public final perPage:Int;
  @:json(
    to = value.map(post -> post.toJson()),
    from = value.map(Post.fromJson)
  )
  @:constant 
  public final items:Array<Post>;
}
