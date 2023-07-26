package blogish.ui.modifier;

import blok.debug.Debug;
import blok.signal.*;
import blok.ui.*;

class BreezeStyles extends Component {
  @:observable final styles:ClassName;
  @:constant final child:Child;

  var previousClasses:String = '';

  function setup() {
    Observer.track(() -> {
      var newClasses:String = styles();
      getAdaptor().updateNodeAttribute(getRealNode(), 'class', previousClasses, newClasses);
      previousClasses = newClasses;
    });
  }

  function render() {
    assert(child.type != Fragment.componentType, 'BreezeStyles cannot be used on Fragments');
    
    return child;
  }
}
