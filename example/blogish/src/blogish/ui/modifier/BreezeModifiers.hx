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

function horizontalLayout(child:Child) {
  return BreezeStyles.node({
    styles: Breeze.compose(
      Flex.display(),
      Flex.direction('row'),
      Flex.gap(3)
    ),
    child: child
  });
}

function verticalLayout(child:Child) {
  return BreezeStyles.node({
    styles: Breeze.compose(
      Flex.display(),
      Flex.direction('column'),
      Flex.gap(3)
    ),
    child: child
  });
}

function centerAlign(child:Child) {
  return BreezeStyles.node({
    styles: Flex.alignItems('center'),
    child: child
  });
}

function constrainWidthToContainer(child:Child) {
  return BreezeStyles.node({
    styles: Breeze.compose(
      Sizing.width('full'),
      Spacing.margin('x', 'auto'),
      Breakpoint.viewport('900px', Sizing.width('900px'))
    ),
    child: child
  });
}
