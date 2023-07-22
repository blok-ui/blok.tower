package blok.tower.cache;

interface Cache<T> {
  public function get(key:String):Task<Maybe<T>>;
  public function set(key:String, value:T, ?lifetime:Float):Task<Nothing>;
  public function remove(key:String):Task<Nothing>;
  public function clear():Task<Nothing>;
}
