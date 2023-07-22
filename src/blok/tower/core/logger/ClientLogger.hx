package blok.tower.core.logger;

import js.Browser.console;
import blok.tower.core.Logger;

class ClientLogger implements Logger {
  public function new() {}

	public function log(level:LogLevel, message:String) {
    switch level {
      case Debug:
        #if debug
        console.debug(message);
        #end
      case Error:
        console.error(message);
      case Info:
        console.info(message);
      case Warning:
        console.warn(message);
    }
  }
}
