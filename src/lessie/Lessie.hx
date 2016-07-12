package lessie;

#if macro
import haxe.macro.Context;
import haxe.macro.Compiler;
using sys.FileSystem;
using haxe.io.Path;
#end

class Lessie { 

  #if macro
  static var postProcessors = [];
  
  static function use() {
    Context.onGenerate(function (types) new Builder().buildLess(types));  
  }
  
  static public function getOutputPath() {
    var outDir = Compiler.getOutput();
    
    if (!outDir.isDirectory())
      outDir = outDir.directory();
    
    return 
      switch Context.definedValue('lessieOutput') {
        case null: '$outDir/styles.css';
        case v: 
          var file = switch v.charAt(0) {
            case '.', '/': v;
            default: '$outDir/$v';
          }
          
          if (file.extension() == "") file += '.css';
          file;
      }    
  }
  static public function postProcess(handler:String->Void) {
    postProcessors.push(handler);
  }
  #end
  
  
  macro static public function getOutput() {
    return macro $v{getOutputPath()};
  }
  
}