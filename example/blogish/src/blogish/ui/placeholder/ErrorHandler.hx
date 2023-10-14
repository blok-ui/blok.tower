package blogish.ui.placeholder;

import blok.html.Html;
import haxe.Exception;
import kit.Error;

using Std;

class ErrorHandler extends Component {
  @:attribute final error:Exception;

  // @todo: Styles and stuff.
  function render() {
    var code:ErrorCode = error.downcast(Error)?.code ?? InternalError;
    return Html.div({},
      Html.header({},
        Html.h1({}, 'Error: $code')  
      ),
      Html.p({}, 'Something went wrong!'),
      #if debug
      Html.p({}, error.message)
      #end
    );
  }
}
