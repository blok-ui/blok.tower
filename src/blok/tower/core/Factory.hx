package blok.tower.core;

abstract Factory<T>(()->T) from () -> T {
  public function new(factory) {
    this = factory;
  }

  public function map(transform:(value:T)->T):Factory<T> {
    return new Factory(() -> transform(create()));
  }

  public function create():T {
    return this();
  }
}
