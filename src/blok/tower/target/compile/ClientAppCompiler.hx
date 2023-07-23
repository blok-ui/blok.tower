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
    var path = Path.join([ 'assets', hash.withExtension('js') ]);
    // // @todo: Figure out how we'll be handling prefixes for the static
    // // path. This is linked up with the server package.
    // var url = Path.join([ context.prefix, path ]);
    var url = '/' + path;
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

    context.output.add(new ClientAppOutput(hash, path, context.target));
  }
}
