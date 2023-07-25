package blok.tower.config;

import blok.tower.file.FileSystem;
import toml.Parser;

class BlokTomlParser {
  final fs:FileSystem;

  public function new(fs) {
    this.fs = fs;
  }

  public function load() {
    return fs.getFile('blok.toml').next(file -> {

    });
  }
}
