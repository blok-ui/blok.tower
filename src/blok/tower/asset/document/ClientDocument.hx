package blok.tower.asset.document;

import js.Browser;

class ClientDocument extends Document {
  function getHead():Dynamic {
    return Browser.document.head;
  }

  function getBody():Dynamic {
    return Browser.document.body;
  }

  function getLayer(id:String):Dynamic {
    var layer = Browser.document.getElementById(id);
    if (layer == null) {
      layer = Browser.document.createDivElement();
      layer.setAttribute('id', id);
      Browser.document.body.appendChild(layer);
    }
    return layer;
  }

  public function toString() {
    return '';
  }
  
  public function setTitle(title:String):Void {
    var el = Browser.document.head.querySelector('title');
    if (el == null) {
      el = Browser.document.createTitleElement();
      Browser.document.head.appendChild(el);
    }
    el.textContent = title;
  }

  public function setMeta(key:String, value:String):Void {
    // todo
  }
}
