package blok.tower.client;

import js.Browser;
import blok.tower.routing.Navigator;
import blok.signal.*;

using Lambda;
using StringTools;

private var isPopState = false;

function getLocation() {
  return Browser.location.pathname + Browser.location.hash + Browser.location.search;
}

function pushLocation(url:String) {
  Browser.window.history.pushState(null, null, url);
}

function watchHistory(subscription:(url:String)->Void):Cancellable {
  function listener(_) {
    var prevPopState = isPopState;
    isPopState = true;
    subscription(getLocation());
    isPopState = prevPopState;
  }
  Browser.window.addEventListener('popstate', listener);
  return () -> Browser.window.removeEventListener('popstate', listener);
}

function bindNavigatorToBrowserHistory(nav:Navigator):Cancellable {
  var obs = new Observer(() -> {
    var request = nav.request();
    if (!isPopState) pushLocation(request.url);
  });

  return [
    () -> obs.dispose(),
    watchHistory(url -> nav.go(url))
  ];
}
