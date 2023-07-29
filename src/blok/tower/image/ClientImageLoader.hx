package blok.tower.image;

abstract ClientImageLoader(Task<String>) to Task<String> {
  public inline function new(src:String) {
    var img = new js.html.Image();
    img.src = src;
    this = if (img.complete) {
      Task.resolve(src);
    } else {
      new Task(activate -> {
        img.addEventListener('load', () -> activate(Ok(src)));
        img.addEventListener('error', _ -> activate(Error(new Error(NotFound, 'Image could not be found'))));
        if (img.complete) activate(Ok(src));
      });
    }
  }
}
