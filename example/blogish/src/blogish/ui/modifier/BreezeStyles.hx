package blogish.ui.modifier;

import blok.debug.Debug;

class BreezeStyles extends Component {
  @:observable final styles:ClassName;
  @:attribute final child:Child;

  var previousClasses:String = '';

  function setup() {
    Observer.track(() -> {
      var newClasses:String = styles();
      getAdaptor().updateNodeAttribute(getPrimitive(), 'class', previousClasses, newClasses);
      previousClasses = newClasses;
    });
  }

  function render() {
    assert(child.type != Fragment.componentType, 'BreezeStyles cannot be used on Fragments');
    
    return child;
  }
}
