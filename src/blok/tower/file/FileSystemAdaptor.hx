package blok.tower.file;

import haxe.io.Bytes;

interface FileSystemAdaptor {
  public function getMeta(path:String):Task<FileMeta>;
  // public function glob(pattern:String):Task<Array<String>>;
  public function listFiles(dir:String):Task<Array<FileMeta>>;
  public function listDirectories(path:String):Task<Array<String>>;
  public function exists(path:String):Task<Bool>;
  public function read(path:String):Task<String>;
  public function readBytes(path:String):Task<Bytes>;
  public function copy(source:String, dest:String):Task<Bool>;
  public function write(path:String, data:String):Task<Bool>;
  public function remove(path:String):Task<Bool>;
}
