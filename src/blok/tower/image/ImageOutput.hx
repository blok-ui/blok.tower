package blok.tower.image;

import blok.data.Model;
import blok.tower.asset.*;
import blok.tower.asset.data.*;
import haxe.io.Path;

using blok.tower.image.ImageGenerator;

class ImageOutput extends Model implements OutputItem {
  @:constant public final key:OutputKey;
  @:constant final source:String;
  @:constant final dest:String;
  @:constant final image:ImageAsset;

  public function process(output:Output):Task<Nothing> {
    output.addToManifest(dest);
    return Task.parallel(
      output.src.getFile(source),
      output.pub.getFile(dest)
    ).next(files -> {
      switch files {
        case [ source, dest ] if (source.meta.created.getTime() > dest.meta.created.getTime()):
          true;
        default:
          false;
      }
    })
    .recover(_ -> Future.immediate(true))
    .flatMap(shouldGenerate -> switch shouldGenerate {
      case true:
        processImage(output.src, output.pub).next(_ -> Nothing);
      case false: 
        Task.nothing();
    });
  }

  function processImage(src:SourceDirectory, pub:PublicDirectory):Task<Nothing> {
    var from = Path.join([ src.meta.path, source ]);
    var out = Path.join([ pub.meta.path, dest ]);
    return switch image.size {
      case Full:
        src.getFile(source)
          .next(file -> file.copy(out))
          .next(_ -> Nothing);
      case Medium:
        from.process(out, {
          engine: image.config.engine,
          width: image.config.mediumSize,
          height: image.config.mediumSize,
          crop: false
        }).next(_ -> Nothing);
      case Thumbnail:
        from.process(out, {
          engine: image.config.engine,
          width: image.config.thumbSize,
          height: image.config.thumbSize,
          crop: true
        }).next(_ -> Nothing);
      case Custom(x, y):
        from.process(out, {
          engine: image.config.engine,
          width: x,
          height: y,
          crop: false
        }).next(_ -> Nothing);
    }
  }
}
