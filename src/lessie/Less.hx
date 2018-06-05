package lessie;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.io.Path;
using sys.io.File;
using StringTools;
using sys.FileSystem;

class Less { 
  
  static public function build(array:Array<String>, output) {
    
    //TODO: this invocation through a file is utter crap. Check again for 3.3
    var file = Path.directory(Context.getPosInfos((macro null).pos).file) + '/build.js';
    
    var input = [for (file in array) '@import \'$file\';'].join(' '),
        cmd = 
          switch Sys.systemName() {
            case 'Windows': 'lessc.cmd';
            default: 'lessc';
          }       
    
    switch '${Sys.getCwd()}/node_modules/.bin/$cmd' {
      case found if (found.exists()): cmd = found;
      default:
    }
    
    switch Sys.command('node', [file, cmd, output, input]) {
      case 0:
        @:privateAccess {
          
          for (p in Lessie.postProcessors)
            p(output);
            
          Lessie.postProcessors = [];
        }
      case v:
        for (line in '$output.errorlog'.getContent().split('\n')) {
          if (line == 'ENOENT') {
            throw 'You need to have lessc installed and available';
          }
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
        Sys.exit(v);
    }
  }
  
  static public function parse(s:String, file:String):{ dependencies:Array<FileRef> } 
    return { dependencies: new Parser(file, s).parseFile() }
  
}
#end