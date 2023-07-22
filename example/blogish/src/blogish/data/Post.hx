package blogish.data;

import blok.tower.data.JsonAware;
import blok.tower.content.Content;

class PostMeta implements JsonAware {
  @:constant public final previous:Null<Post>;
  @:constant public final next:Null<Post>;
}

class Post implements JsonAware {
  @:constant public final meta:Null<PostMeta> = null;
  @:constant public final slug:String;
  @:constant public final title:String;
  @:constant public final tags:Array<String>;
  @:constant public final content:Content;
}
