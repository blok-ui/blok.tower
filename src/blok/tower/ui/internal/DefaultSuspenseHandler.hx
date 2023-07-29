package blok.tower.ui.internal;

import blok.ui.*;
import blok.html.*;

class DefaultSuspenseHandler extends Component {
  // @todo: Fix up styles and branding here!
  function render() {
    return Html.div({}, Html.p({}, 'Loading...'));
  }
}