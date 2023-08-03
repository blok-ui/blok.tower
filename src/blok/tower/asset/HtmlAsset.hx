package blok.tower.asset;

import blok.data.Model;

using StringTools;
using haxe.io.Path;

class HtmlAsset extends Model implements Asset {
  @:constant final path:String;
  @:constant final content:String;

  public function register(context:AssetContext) {
    if (context.target.shouldOutputHtml()) context.output.add(new HtmlOutput({
      key: path,
      path: path,
      content: content
    }));
  }
}

class HtmlOutput extends Model implements OutputItem {
  @:constant public final key:OutputKey;
  @:constant final path:String;
  @:constant final content:String;

  public function process(context:Output):Task<Nothing> {
    var path = path.trim().normalize();
    if (path.startsWith('/')) path = path.substr(1);
    // @todo: allow other output modes -- some hosts don't need
    // an index.html in a folder to work
    var dest = Path.join([ path, 'index.html' ]);
    var file = context.pub.createFile(dest);
    return file.write(content);
  }
}
