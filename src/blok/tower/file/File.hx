package blok.tower.file;

class File {
  public final path:String;
  public final meta:FileMeta;
  final adaptor:FileSystemAdaptor;

  public function new(meta, adaptor) {
    this.meta = meta;
    this.path = meta.path;
    this.adaptor = adaptor;
  }

  public function read() {
    return adaptor.read(path);
  }

  public function readBytes() {
    return adaptor.readBytes(path);
  }

  public function write(data:String) {
    return adaptor.write(path, data);
  }

  public function copy(dest:String) {
    return adaptor.copy(path, dest);
  }

  public function remove() {
    return adaptor.remove(path);
  }
}
