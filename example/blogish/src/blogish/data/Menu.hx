package blogish.data;

import blok.data.Model;

class Menu extends Model {
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

class MenuOption extends Model {
  @:constant public final label:String;
  @:constant public final type:MenuOptionType;
  @:constant public final url:String;
}
