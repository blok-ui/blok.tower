package blok.tower.target;

class Visitor {
  final visited:Array<String> = [];
  var pending:Array<String> = [];

  public function new() {}

  public function visit(path:String) {
    if (didVisit(path)) return;
    pending.push(path);
  }

  public function didVisit(path:String):Bool {
    return visited.contains(path) || pending.contains(path);
  }

  public function hasPending() {
    return pending.length != 0;
  }

  public function drain(each:(path:String)->Task<Dynamic>):Task<Nothing> {
    var toVisit = pending.copy();
    pending = [];
    
    return Task.parallel(...toVisit.map(path -> {
      visited.push(path);
      each(path);
    })).next(_ -> Nothing);
  }
}
