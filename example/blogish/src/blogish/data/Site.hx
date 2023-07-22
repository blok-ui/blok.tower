package blogish.data;

import blok.tower.data.JsonAware;

class Site implements JsonAware {
  @:constant public final title:String;
  @:constant public final menu:Menu;
}
