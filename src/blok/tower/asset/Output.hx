package blok.tower.asset;

import kit.file.Directory;
#if !blok.tower.client
import blok.tower.asset.data.*;
import haxe.Json;
import kit.file.FileSystem;

using haxe.io.Path;
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
  final manifest:OutputManifest = [];

  public function new(root, src, pub, priv) {
    this.root = root;
    this.src = src;
    this.pub = pub;
    this.priv = priv;
  }

  public function add(item:OutputItem) {
    items.set(item.key, item);
  }

  public function addToManifest(path:String) {
    path = Path.join([ pub.meta.path, path ]);
    if (manifest.contains(path)) return;
    manifest.push(path);
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
    return batch()
      .next(_ -> priv.createFile('manifest.json').write(Json.stringify({
        files: manifest
      }, '  ')))
      .next(_ -> cleanup());
  }

  function cleanup():Task<Nothing> {
    return pub.listDirectories()
      .next(dirs -> Task.parallel(...dirs.map(cleanupDir)))
      .next(_ -> Nothing);
  }

  function cleanupDir(dir:Directory) {
    return dir.listFiles().next(files -> {
      for (file in files) {
        // @todo: Still not sure about this.
        if (!manifest.contains(file.meta.path)) file.remove();
      }
      return Nothing;
    }).next(_ -> dir.listDirectories()
        .next(dirs -> Task.parallel(...dirs.map(cleanupDir)))
        .next(_ -> Nothing)
    );
  }
  #end
}