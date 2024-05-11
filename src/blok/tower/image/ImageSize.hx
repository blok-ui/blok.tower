package blok.tower.image;

@:using(ImageSize.ImageSizeTools)
enum ImageSize {
  Full;
  Medium;
  Thumbnail;
  Custom(x:Int, y:Int);
}

class ImageSizeTools {
  public static function fromJson(json:Dynamic):ImageSize {
    return switch json {
      case 'Full': Full;
      case 'Medium': Medium;
      case 'Thumbnail': Thumbnail;
      case obj if (Reflect.hasField(obj, 'x') && Reflect.hasField(obj, 'y')): 
        Custom(Reflect.field(obj, 'x'), Reflect.field(obj, 'y'));
      default: Full;
    }
  }
  
  public static function toJson(image:ImageSize):Dynamic {
    return switch image {
      case Full: 'Full';
      case Medium: 'Medium';
      case Thumbnail: 'Thumbnail';
      case Custom(x, y): {x: x, y: y};
    }
  }
}
