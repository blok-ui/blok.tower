package blok.tower.target.compile;

import blok.tower.asset.*;

class ClientAppOutput implements OutputItem {
  public final key:OutputKey;

  public function new(key) {
    this.key = key;
  }

  public function process(output:Output):Task<Nothing, Error> {
    throw new haxe.exceptions.NotImplementedException();
  }
}
