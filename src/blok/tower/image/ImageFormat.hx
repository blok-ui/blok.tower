package blok.tower.image;

enum abstract ImageFormat(String) from String to String {
  var Jpg = 'jpeg';
  var Png = 'png';
  var Gif = 'gif';
  var Bmp = 'bmp';
  var Tiff = 'tiff';
  var WebP = 'webp';
}
