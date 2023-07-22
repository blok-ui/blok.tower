package blok.tower.core.logger;

import cmdr.Output;
import blok.tower.core.Logger;

using cmdr.StyleTools;

class ServerLogger implements Logger {
  final output:Output;

  public function new(output) {
    this.output = output;
  }

  public function log(level:LogLevel, message:String) {
    if (shouldLog(level)) {
      output.writeLn(format(level, message));
    }
  }

  // @todo: Make this more robust
  function shouldLog(level:LogLevel):Bool {
    return switch level {
      case Debug: #if debug true #else false #end;
      default: true; // @todo: make this configurable
    }
  }

  function format(level:LogLevel, message:String) {
    var label = switch level {
      case Debug: ' debug '.backgroundColor(Yellow).bold();
      case Info: ' info '.backgroundColor(Blue).bold();
      case Warning: ' warning '.backgroundColor(Cyan).bold();
      case Error: ' error '.backgroundColor(Red).bold();
    }
    return [ label, message ].join(' ');
  }
}
