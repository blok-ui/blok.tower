package blogish.pages.images;

import blok.tower.image.*;
import blok.ui.*;
import blok.tower.routing.PageRoute;

class ShowImagePage implements PageRoute<'/images'> {
  public function render(context:ComponentBase):Child {
    return Fragment.node(
      Image.node({
        src: 'media/test.png',
        alt: 'Test',
        size: ImageSize.Full,
        loading: () -> 'Loading',
        failed: message -> message
      }),
      Image.node({
        src: 'media/test.png',
        alt: 'Test',
        size: ImageSize.Thumbnail,
        loading: () -> 'Loading',
        failed: message -> message
      }),
    );
  }
}
