package blogish.data;

import blok.tower.data.JsonAware;

class Menu implements JsonAware {
  public inline static function empty():Menu {
    return new Menu({ id: '<empty>', options: [] });
  }

  @:constant public final id:String;
  @:constant public final options:Array<MenuOption>;
}

enum abstract MenuOptionType(String) {
  var InternalLink = 'internal';
  var ExternalLink = 'external';
}

class MenuOption implements JsonAware {
  @:constant public final label:String;
  @:constant public final type:MenuOptionType;
  @:constant public final url:String;
}
