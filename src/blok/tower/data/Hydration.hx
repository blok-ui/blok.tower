package blok.tower.data;

import js.Browser;

using Reflect;

class Hydration {
  final id:HydrationId;
  final hydrationData:Map<String, {}> = new Map();

  public function new(id) {
    this.id = id;
    if (Browser.window.hasField(id)) {
      var json:Dynamic = Browser.window.field(id);
      for (id in json.fields()) {
        hydrationData.set(id, json.field(id));
      }
    }
  }

  public function extract(hash:String):Maybe<{}> {
    if (hydrationData.exists(hash)) {
      var data = hydrationData.get(hash);
      hydrationData.remove(hash);
      return Some(data);
    }
    return None;
  }
}
