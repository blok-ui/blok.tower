package blok.tower.target.compile;

import blok.html.server.Element;
import blok.tower.asset.*;
import blok.tower.core.*;

using haxe.io.Path;
using kit.Hash;

class ClientAppCompiler implements Asset {
  final version:AppVersion;

  public function new(version) {
    this.version = version;
  }

  public function register(context:AssetContext) {
    var hash = ('blok-tower-app' + version.toFileNameSafeString()).hash();
    var url = context.config.path.createAssetUrl(hash).withExtension('js');
    var path = context.config.path.createAssetOutputPath(hash).withExtension('js');
    var head:Element = context.document.getHead();

    #if debug
    head.append(new Element('script', {
      src: url,
      defer: true,
      type: 'text/javascript'
    }));
    #else
    head.append(new Element('script', {
      src: url.withExtension('min.js'),
      defer: true,
      type: 'text/javascript'
    }));
    #end

    context.output.add(new ClientAppOutput(hash, path, context.config.output.target));
  }
}
