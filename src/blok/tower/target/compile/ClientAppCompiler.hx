package blok.tower.target.compile;

import blok.html.server.Element;
import blok.tower.asset.*;
import blok.tower.config.Config;

using haxe.io.Path;
using kit.Hash;

class ClientAppCompiler implements Asset {
  final config:Config;

  public function new(config) {
    this.config = config;
  }

  public function register(context:AssetContext) {
    #if debug
    var hash = config.name + config.version.toFileNameSafeString();
    #else
    var hash = (config.name + config.version.toFileNameSafeString()).hash();
    #end
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

    context.output.add(new ClientAppOutput(hash, path, config));
  }
}
