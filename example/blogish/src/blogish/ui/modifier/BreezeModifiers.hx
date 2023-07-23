package blogish.ui.modifier;

import Breeze;
import blok.signal.Signal;
import blok.ui.Child;

function styles(child:Child, ...classes:ClassName) {
  return BreezeStyles.node({
    styles: ClassName.ofArray(classes),
    child: child
  });
}

function observedStyles(child:Child, styles:ReadonlySignal<ClassName>) {
  return BreezeStyles.node({
    styles: styles, 
    child: child
  });
}
