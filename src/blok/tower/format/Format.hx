package blok.tower.format;

interface Format<T> {
  public function parse(str:String):Task<T>;
}
