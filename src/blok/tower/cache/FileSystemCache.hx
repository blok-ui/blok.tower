package blok.tower.cache;

import kit.file.*;

using StringTools;
using haxe.io.Path;
using kit.Hash;

class FileSystemCache implements Cache<String> {
  final directory:Directory;
  final lifetime:Null<Float>;
  final prefix:String;

  public function new(directory, ?lifetime, ?prefix) {
    this.directory = directory;
    this.lifetime = lifetime;
    this.prefix = prefix ?? '__blok_tower_';
  }

  public function get(key:String):Task<Maybe<String>> {
    return directory.getFile(preparePath(key)).next(file -> {
      if (lifetime != null) {
        var current = file.meta.created.getTime() - Date.now().getTime();
        if (current >= lifetime) {
          return file.remove().next(_ -> None);
        }
      }
      return file.read().next(data -> Some(data));
    });
  }

  public function set(key:String, value:String, ?lifetime:Float):Task<Nothing> {
    return directory.createFile(preparePath(key)).write(value);
  }

  public function remove(key:String):Task<Nothing> {
    return directory.getFile(preparePath(key)).next(file -> file.remove());
  }

  public function clear():Task<Nothing> {
    return directory.exists().flatMap(exists -> {
      if (!exists) return Task.resolve(Nothing);
      return directory.listFiles()
        .next(files -> files.filter(file -> {
          if (prefix != null && !file.meta.name.startsWith(prefix)) return false;
          file.meta.path.extension() == 'txt';
        }))
        .next(files -> Task.sequence(...files.map(file -> file.remove())))
        .next(_ -> Nothing);
    });
  }
  
  inline function preparePath(key:String) {
    return (prefix + key.hash()).withExtension('txt');
  }
}
