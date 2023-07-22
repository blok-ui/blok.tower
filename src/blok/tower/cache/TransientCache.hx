package blok.tower.cache;

using DateTools;

class TransientCache<T> implements Cache<T> {
  public inline static final ONE_MINUTE = 60000;
  public inline static final ONE_HOUR = 3600000;
  public inline static final ONE_DAY = 86400000;

  var lifetime:Float;
  var items:Map<String, CacheItem<T>> = [];

  public function new(lifetime) {
    this.lifetime = lifetime;
  }

  public function get(key:String):Task<Maybe<T>> {
    if (!items.exists(key)) return Future.immediate(None);
    var item = items.get(key);
    if (item.invalid()) {
      items.remove(key);
      return Future.immediate(None);
    }
    return Future.immediate(Some(item.get()));
  }

  public function set(key:String, value:T, ?lifetime:Float):Task<Nothing> {
    if (lifetime == null) lifetime = this.lifetime;
    var time = Date.now().delta(lifetime);
    items.set(key, new CacheItem(value, time));
    return Nothing;
  }

  public function remove(key:String):Task<Nothing> {
    items.remove(key);
    return Nothing;
  }

  public function clear():Task<Nothing> {
    items.clear();
    return Nothing;
  }
}
