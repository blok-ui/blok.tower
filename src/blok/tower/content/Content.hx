package blok.tower.content;

import blok.tower.data.JsonAware;

class Content<Data = Dynamic> implements JsonAware {
  @:constant public final type:String;
  @:constant public final data:Data;
  @:constant public final children:Array<Content> = [];
}
