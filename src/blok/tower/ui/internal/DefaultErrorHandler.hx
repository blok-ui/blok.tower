package blok.tower.ui.internal;

import blok.html.*;
import blok.ui.*;
import haxe.Exception;
import kit.Error;

class DefaultErrorHandler extends Component {
  @:constant final error:Exception;

  // @todo: Fix up styles and branding here!
  // Ideally this would have handy developer friendly stuff available.
  function render() {
    var code:ErrorCode = Std.downcast(error, kit.Error)?.code ?? InternalError;
    return Html.div({ style: '
      max-width: 900px;
      margin: 30px auto;
      padding: 15px;
      color: white;
      background-color: red;
      border-radius: 10px;
      font-size: 15px;
    ' }, 
      Html.h1({
        style: '
          font-size: 25px;
          font-weight: bold;
          padding-bottom: 5px;
          margin-bottom: 5px;
          border-bottom: 1px solid white;
        '
      }, 'Error: $code'),
      Html.div({},
        Html.p({}, 'Something went wrong!'),
        #if debug
        Html.p({}, error.message)
        #end 
      ),
      Html.footer({},
        #if debug
        Html.p({}, 'Note: this is the default Blok Tower error handler.'
        + ' You are strongly encouraged to override it and provide'
        + ' your own.')
        #end
      )
    );
  }
}
