package blok.tower.image;

import blok.data.Model;

class ImageConfig extends Model {
  @:constant public final mediumSize:Int = 800;
  @:constant public final thumbSize:Int = 200;
  #if !blok.tower.client
  @:constant public final engine:ImageEngine = Vips;
  #end
}
