package blogish.ui.page;

import blok.html.*;

class PageContent extends Component {
  @:attribute final children:Children;

  function render() {
    return Html.div({}, ...children.toArray()).styles(
      Spacing.pad(3)
    ).constrainWidthToContainer();
  }
}