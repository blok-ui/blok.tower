package blok.tower.cli;

using haxe.io.Path;
using StringTools;

function createNodeCommand(program:String) {
  var path = Path.join([
    'node_modules',
    '.bin',
    program
  ]);
  
  if (Sys.systemName() == 'Windows') {
    path = path
      .withExtension('cmd')
      .normalize()
      .replace('/', '\\');
  } else {
    path = './${path}';
  }

  if (!sys.FileSystem.exists(path)) {
    // Try using a global command.
    path = program;
  }
  
  return path;
}
