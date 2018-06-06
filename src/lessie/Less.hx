package lessie;

#if macro
import haxe.macro.Context;
using sys.io.File;
using sys.FileSystem;
using StringTools;

class Less { 
  static var isWindows = Sys.systemName() == 'Windows';

  static public function build(array:Array<String>, output) {
    
    function run(cmd:String, args:Array<String>, ?stdin:String) {
      
      var p = new sys.io.Process(cmd, args);
      
      if (stdin != null)
        p.stdin.writeString(stdin);
      
      p.stdin.close();
      
      var stderr = p.stderr.readAll().toString(),
          stdout = p.stdout.readAll().toString();

      return {
        code: p.exitCode(true),
        stderr: stderr,
        stdout: stdout,
        both: stderr + stdout,
      }
    }

    var cmd = if (isWindows) 'lessc.cmd' else 'lessc';
    
    switch '${Sys.getCwd()}/node_modules/.bin/$cmd' {
      case found if (found.exists()): cmd = found;
      default:
        if (isWindows) switch run('where', [cmd]) {
          case { code: 0, stdout: v }: 
            cmd = v.trim();
          case v: 
            Sys.print(v.both);
            Sys.exit(v.code);
        }
    }

    switch run(cmd, ['-', output, '--no-color'], [for (file in array) '@import \'$file\';'].join(' ')) {
      case { code: 0 }:
      case v:
        for (line in v.stderr.split('\n')) 
          if (line.split(' ')[0].endsWith('Error:')) {
            switch line.lastIndexOf(' in ') {
              case -1: //something's weird here
              case v:
                var message = line.substr(0, v);
                var pos = line.substr(v + 4);
                
                switch pos.lastIndexOf(' on line ') {
                  case -1: //something's weird here
                  case start: 
                    var lineNumber = Std.parseInt(pos.substr(start + 9)) - 1,
                        file = pos.substr(0, start).trim();
                        
                    var min = 0,
                        lines = file.getContent().split('\n');
                        
                    for (i in 0...lineNumber)
                      min += lines[i].length + 1;
                      
                    var max = min + lines[lineNumber].length;
                    
                    Context.error(message, Context.makePosition( { file: file, min: min, max: max } ));
                }
            }
          }       
    }
  }
  
  static public function parse(s:String, file:String):{ dependencies:Array<FileRef> } 
    return { dependencies: new Parser(file, s).parseFile() }
  
}
#end