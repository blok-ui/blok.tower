package blok.tower.format;

class TextFormat implements Format<String> {
  public function new() {}

  public function parse(content:String):Task<String> {
    return content;
  }
}
