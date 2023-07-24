package blogish.pages;

import blok.html.*;
import blok.tower.core.Logger;
import blok.tower.routing.PageRoute;

class HomePage implements PageRoute<'/'> {
  @:inject final logger:Logger;

  function render(context:blok.ui.ComponentBase) {
    return Html.div({},
      BlogPostPage.link({ slug: 'first-post' }, 'First Post Link')
    );
  }
}
