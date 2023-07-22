package blok.tower.cache;

class PersistentCache<T> implements Cache<T> {
  final data:Map<String, T> = [];

  public function new() {}

  public function get(key:String):Task<Maybe<T>> {
    var result = data.get(key);
    return result == null ? None : Some(result);
  }

  public function set(key:String, value:T, ?lifetime:Float):Task<Nothing> {
    data.set(key, value);
    return Nothing;
  }

  public function remove(key:String):Task<Nothing> {
    data.remove(key);
    return Nothing;
  }

  public function clear():Task<Nothing> {
    data.clear();
    return Nothing;
  }
}
