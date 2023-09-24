package blok.tower.image;

import blok.html.*;
import blok.html.HtmlEvents;
import blok.suspense.Resource;
import blok.ui.*;

using blok.boundary.BoundaryModifiers;
using blok.suspense.SuspenseModifiers;

class Image extends Component {
  @:observable final wrapperClassName:String = '';
  @:observable final className:String = '';
  @:observable final src:String;
  @:observable final alt:String;
  @:observable final size:ImageSize = ImageSize.Full;
  @:constant final onClick:EventListener = null;
  @:constant final onTouchStart:EventListener = null;
  @:constant final onTouchEnd:EventListener = null;
  @:constant final loading:()->Child;
  @:constant final failed:(message:String)->Child;
  
  function render() {
    return ImageLoader.node({
      src: src,
      size: size,
      child: (image, assetContext) -> {
        var res = new Resource(() -> image.load(assetContext, __renderMode == Hydrating));
        return Html.figure({ className: wrapperClassName },
          Scope
            .wrap(_ -> Html.img({ 
              className: className,
              src: res(), 
              alt: alt,
              onClick: onClick,
              onTouchStart: onTouchStart,
              onTouchEnd: onTouchEnd
            }))
            .inSuspense(loading)
            .inErrorBoundary((_, e) -> failed(e.message))
        );
      }
    });
  }
}
