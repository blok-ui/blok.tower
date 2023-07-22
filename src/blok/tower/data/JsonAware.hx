package blok.tower.data;

@:autoBuild(blok.macro.ReactiveObjectBuilder.build())
@:autoBuild(blok.tower.data.JsonAwareBuilder.build())
interface JsonAware {
  public function toJson():Dynamic;
}
