package ;

import haxe.macro.Compiler;
import sys.FileSystem;
import sys.io.File;
import travix.Logger.*;
import Fake;

@:less('test.less')
class RunTests {

  static function main() {
    var dce = Compiler.getDefine('dce') == 'full';

    switch File.getContent(lessie.Lessie.getOutput()).indexOf('.skip') {
      case -1 if (dce):
      case -1 if (!dce):
        println('Did not find .skip with dce turned off');
        exit(1);
      case _ if (dce): 
        println('Found .skip despite dce');
        exit(1);
    }
    
    exit(0); // make sure we exit properly, which is necessary on some targets, e.g. flash & (phantom)js
  }
  
}