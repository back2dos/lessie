package lessie;

import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.io.Path;
import sys.io.File;

class Less { 
  
  static public function build(array:Array<String>) {
    //TODO: this invocation through a file is utter crap. Check again for 3.3
    var file = Path.directory(Context.getPosInfos((macro null).pos).file) + '/build.js';
    
    var output = Compiler.getOutput().withoutExtension().withExtension('css'),
        input = [for (file in array) '@import \'$file\';'].join('\n'),
        cmd = switch Sys.systemName() {
          case 'Windows': 'lessc.cmd';
          default: 'lessc';
        }
        
    switch Sys.command('node', [file, cmd, output, input]) {
      case 0:
        
      case v:
        Sys.exit(v);
    }
  }
  
  static public function parse(s:String, file:String):{ dependencies:Array<FileRef> } {
  
    var pos = 0,
        deps = [];
        
    function makePos(start, end)
      return Context.makePosition( { min: start, max: end, file: file } );
    
    function flush(to:Int) {
      
      while (pos < to) 
        switch s.indexOf('@import', pos) {
          case -1: break;
          case v: 
            
            pos += '@import'.length;
            
            while (StringTools.isSpace(s, pos)) pos++;
            
            var start = pos;
            if (s.charAt(start) != '"')
              Context.error('expected import argument starting with double quotes', makePos(start, start+1));
              
            var end = s.indexOf('"', start+1);
            
            if (end == -1) {
              Context.error('unclosed file name', makePos(v, start));
            }
            
            deps.push({
              name: Path.join([Path.directory(file), s.substring(start + 1, end)]),
              from: makePos(start, end+1)
            });
            
            pos = end + 1;
        }
        
    }
    
    while (pos < s.length) 
      switch [s.indexOf('//', pos), s.indexOf('/*', pos)] {
        case [-1, -1]:
          flush(s.length);
          pos = s.length;
        case [line, block] if (line < block):
          flush(line);
          pos = switch s.indexOf('\n', line) {
            case -1: s.length;
            case v: v + 1;
          }
        case [_, block]:
          flush(block);
          
          pos = switch s.indexOf('*/', block+2) {
            case -1: s.length;
            case v: v + 2;
          }

      }
    
    return { dependencies: deps };
  }
  
}