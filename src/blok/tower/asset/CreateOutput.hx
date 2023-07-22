package blok.tower.asset;

import blok.data.Record;

class CreateOutput extends Record implements OutputItem {
  @:constant public final key:OutputKey;
  @:constant final dest:String;
  @:constant final content:String;

  public function process(context:Output):Task<Nothing> {
    return context.pub.createFile(dest).write(content);
  }
}
