package blogish.ui.page;

import blok.html.*;

class PageHeader extends Component {
  @:attribute final title:String;

  function render() {
    return Html.header({},
      Html.div({},
        Html.h2({}, title).styles(
          Typography.fontSize('xxl'),
          Typography.fontWeight('bold')
        )
      ).horizontalLayout()
        .centerAlign()
        .constrainWidthToContainer()
        .styles(
          Spacing.pad(3),
          Sizing.height('full')
        )
    ).styles(
      Sizing.height(20),
      Background.color('gray', 300)
    );
  }
}
