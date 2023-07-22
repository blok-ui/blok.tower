package blok.tower.content;

import blok.ui.*;

class ContentComponent extends Component {
  @:constant final content:Content;

  public function render():Child {
    return ContentRenderer.from(this).render(content);
  }
}
