package blok.tower.config;

class UserConfigFactory implements ConfigFactory {
  final create:()->Config;

  public function new(create) {
    this.create = create;
  }

  public function createConfig():Config {
    return create();
  }
}
