package blogish.layouts;

import blok.ui.*;
import blok.tower.routing.LayoutRoute;

class ImageLayout implements LayoutRoute<'blogish.pages.images'> {
  function render(context:ComponentBase, router:Child):Child {
    return router;
  }
}
