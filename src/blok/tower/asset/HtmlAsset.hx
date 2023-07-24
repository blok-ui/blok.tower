package blok.tower.asset;

import blok.data.Model;

using StringTools;
using haxe.io.Path;

class HtmlAsset extends Model implements Asset {
  @:constant final path:String;
  @:constant final content:String;

  public function register(context:AssetContext) {
    switch context.target {
      case StaticSiteGeneratedTarget:
        context.output.add(new HtmlOutput({
          key: path,
          path: path,
          content: content
        }));
      default:
    }
  }
}

class HtmlOutput extends Model implements OutputItem {
  @:constant public final key:OutputKey;
  @:constant final path:String;
  @:constant final content:String;

  public function process(context:Output):Task<Nothing> {
    var path = path.trim().normalize();
    if (path.startsWith('/')) path = path.substr(1);
    var dest = Path.join([ path, 'index.html' ]);
    var file = context.pub.createFile(dest);
    return file.write(content);
  }
}
