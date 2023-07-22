package blok.tower.file;

using haxe.io.Path;

class Directory {
  public final name:String;
  public final path:String;
  final adaptor:FileSystemAdaptor;

  public function new(path, adaptor) {
    this.path = path;
    this.name = path.withoutDirectory();
    this.adaptor = adaptor;
  }

  public function exists() {
    return adaptor.exists(path);
  }

  public function getFile(path:String) {
    return adaptor
      .getMeta(preparePath(path))
      .next(meta -> new File(meta, adaptor));
  }

  public function createFile(path:String):File {
    return new File({
      path: preparePath(path),
      name: path.withoutDirectory().withoutExtension(),
      created: Date.now(),
      updated: Date.now(),
      size: 0
    }, adaptor);
  }

  public function listFiles() {
    return adaptor
      .listFiles(path)
      .next(metas -> [ for (meta in metas) new File(meta, adaptor) ]);
  }

  public function openDirectory(name:String) {
    return new Directory(Path.join([ path, name ]), adaptor);
  }

  public function listDirectories() {
    return adaptor
      .listDirectories(path)
      .next(paths -> [ for (path in paths) new Directory(path, adaptor) ]);
  }

  public function remove() {
    adaptor.remove(path);
  }

  function preparePath(path:String) {
    return Path.join([ this.path, path ]);
  }
}
