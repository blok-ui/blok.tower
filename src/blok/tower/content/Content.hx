package blok.tower.content;

import blok.data.Model;

class Content<Data = Dynamic> extends Model {
  @:constant public final type:String;
  @:constant public final data:Data;
  @:constant public final children:Array<Content> = [];
}
