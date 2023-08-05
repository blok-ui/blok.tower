package blogish.layouts;

import blogish.pages.HomePage;
import blok.html.Html;
import blok.ui.*;
import blok.tower.routing.LayoutRoute;

class ImageLayout implements LayoutRoute<'blogish.pages.images'> {
  function render(context:ComponentBase, router:Child):Child {
    return Fragment.node(
      Html.div({}, 
        HomePage.link({}, 'Return home')  
      ),
      router
    );
  }
}
