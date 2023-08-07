package blogish.ui.site;

import haxe.macro.Compiler;
import blogish.data.Site;
import blok.tower.ui.*;
import blok.html.*;

using haxe.io.Path;

class SiteHead extends Component {
  @:constant final site:Site;

  function render() {
    var stylesPath = Compiler.getDefine('breeze.output')?.withExtension('css') ?? 'styles.css';
    return Head.node({
      children: [
        Html.title({}, site.title),
        Html.meta({ name: 'viewport', content: 'width=device-width, initial-scale=1' }),
        Style.node({ src: stylesPath, kind: Generated })
      ]
    });
  }
}