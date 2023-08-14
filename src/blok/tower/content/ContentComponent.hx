package blok.tower.content;

import blok.ui.*;

class ContentComponent extends Component {
  @:constant final content:Content;

  public function render():Child {
    return ContentContext.from(this).render(content);
  }
}
