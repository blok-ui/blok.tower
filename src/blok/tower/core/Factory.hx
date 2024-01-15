package blok.tower.core;

@:callable
abstract Factory<T>(()->T) from () -> T to () -> T {
  public inline function new(factory) {
    this = factory;
  }

  public inline function map(transform:(value:T)->T):Factory<T> {
    return new Factory(() -> transform(create()));
  }

  public inline function create():T {
    return this();
  }
}
