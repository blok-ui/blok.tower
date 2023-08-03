package blogish.pages.images;

import blok.ui.*;
import blok.tower.routing.PageRoute;

class ShowImagePage implements PageRoute<'/images/{name:String}'> {
  public function render(context:ComponentBase):Child {
    return Placeholder.node();
  }
}
