package blok.tower.asset;

#if !blok.tower.client
import blok.tower.file.FileSystem;
import blok.tower.asset.data.*;
#end

class Output {
  #if blok.tower.client
  public function new() {}

  public function add(item:OutputItem) {}

  public function process():Task<Nothing> {
    return Nothing;
  }
  #else
  public final root:FileSystem;
  public final src:SourceDirectory;
  public final pub:PublicDirectory;
  public final priv:PrivateDirectory;
  final items:Map<String, OutputItem> = [];

  public function new(root, src, pub, priv) {
    this.root = root;
    this.src = src;
    this.pub = pub;
    this.priv = priv;
  }

  public function add(item:OutputItem) {
    items.set(item.key, item);
  }

  public function process():Task<Nothing> {
    var allItems = [ for (_ => value in items) value ];
    function batch() {
      var items = allItems.slice(0, 100);
      allItems = allItems.slice(100);
      return Task
        .parallel(...items.map(item -> item.process(this)))
        .next(_ -> {
          if (allItems.length > 0) return batch();
          return Nothing;
        });
    }
    return batch();
  }
  #end
}