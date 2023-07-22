package blok.tower.core;

enum abstract LogLevel(Int) {
  final Debug = 0;
  final Info;
  final Warning;
  final Error;
}

typedef LoggerOptions = {
  // @todo: Should be able to configure logging levels etc here.
}

interface Logger {
  public function log(level:LogLevel, message:String):Void;
}
