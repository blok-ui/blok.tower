package blogish.pages;

import blogish.ui.page.*;
import blok.tower.core.Logger;
import blok.tower.routing.PageRoute;

class HomePage implements PageRoute<'/'> {
  @:inject final logger:Logger;

  function render(context:blok.ui.ComponentBase) {
    return Fragment.node(
      PageHeader.node({ title: 'Home' }),
      PageContent.node({
        children: BlogPostPage.link({ slug: 'first-post' }, 'First Post Link')
      })
    );
  }
}
