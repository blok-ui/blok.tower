package blogish.data;

import blok.data.Model;
import blok.tower.content.Content;

class PostMeta extends Model {
  @:constant public final previous:Null<Post>;
  @:constant public final next:Null<Post>;
}

class Post extends Model {
  @:constant public final meta:Null<PostMeta> = null;
  @:constant public final slug:String;
  @:constant public final title:String;
  @:constant public final tags:Array<String>;
  @:constant public final content:Content;
}
