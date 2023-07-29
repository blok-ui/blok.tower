package blok.tower.image;

enum abstract ImageEngine(String) to String {
	final Vips = 'vips';
	final ImageMagick = 'imagemagick';
	final GraphicsMagick = 'graphicsmagick';
	final GD = 'gd';
}
