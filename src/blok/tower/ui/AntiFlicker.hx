package blok.tower.ui;

import haxe.Timer;
import blok.suspense.SuspenseBoundary;
import blok.ui.*;

// This does not work

class AntiFlicker extends Component {
  @:attribute final delay:Int = 1000;
  @:attribute final fallback:()->Child;
  @:attribute final child:Child;

  var timer:Null<Timer>;
  var previous:Null<Child> = null;

  function setup() {
    previous = child;
    addDisposable(() -> {
      previous = null;
      timer?.stop();
      timer = null;
    });
  }

  function render() {
    return SuspenseBoundary.node({
      fallback: () -> previous ?? fallback(),
      onSuspended: () -> {
        timer?.stop();
        timer = Timer.delay(() -> {
          previous = null;
          invalidate();
        }, delay);
      },
      onComplete: () -> {
        timer?.stop();
        timer = null;
        previous = child;
      },
      child: child
    });
  }
}
