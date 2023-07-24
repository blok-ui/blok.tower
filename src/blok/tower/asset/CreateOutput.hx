package blok.tower.asset;

import blok.data.Model;

class CreateOutput extends Model implements OutputItem {
  @:constant public final key:OutputKey;
  @:constant final dest:String;
  @:constant final content:String;

  public function process(context:Output):Task<Nothing> {
    return context.pub.createFile(dest).write(content);
  }
}
