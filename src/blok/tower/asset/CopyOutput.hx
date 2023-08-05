package blok.tower.asset;

import blok.data.Model;
import haxe.io.Path;
import blok.tower.asset.data.*;

class CopyOutput extends Model implements OutputItem  {
  @:constant public final key:OutputKey;
  @:constant final source:String;
  @:constant final dest:String;

  public function process(output:Output):Task<Nothing> {
    var path = Path.join([ output.pub.path, dest ]);
    output.addToManifest(path);
    return isNewer(output.src, output.pub, source, dest).next(newer -> {
      if (!newer) return Nothing;
      return output.src
        .getFile(source)
        .next(file -> file.copy(path));
    });
  }

  function isNewer(src:SourceDirectory, pub:PublicDirectory, source, dest):Task<Bool> {
    return Task
      .parallel(src.getFile(source), pub.getFile(dest))
      .next(files -> switch files {
        case [ a, b ] if (a.meta.created.getTime() > b.meta.created.getTime()):
          true;
        default:
          false;
      })
      .recover(_ -> Future.immediate(true));
  }
}
