package blogish.ui.site;

import blogish.data.Site;
import blok.tower.ui.*;
import blok.html.*;

using haxe.io.Path;

class SiteHead extends Component {
  @:attribute final site:Site;

  function render() {
    return Head.node({
      children: [
        Html.title().child(site.title).node(),
        Html.meta({ 
          name: 'viewport', 
          content: 'width=device-width, initial-scale=1' 
        }).node(),
      ]
    });
  }
}