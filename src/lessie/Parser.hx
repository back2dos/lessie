package lessie;

#if macro
import tink.parse.Char.*;
import tink.core.Error;
import haxe.io.Path;
using StringTools;
using tink.CoreApi;

class Parser extends tink.parse.ParserBase<Pos, Error> {
  var fileName:String;
  
  public function new(fileName, source) {
    super(source);
    this.fileName = fileName;
  }

  override function doSkipIgnored() 
    doReadWhile(WHITE);

  override function makeError(message:String, pos:Pos):Error 
    return new Error(message, pos);

  override function doMakePos(from:Int, to:Int):Pos 
    return 
      haxe.macro.Context.makePosition({
        min: from, max: to, file: fileName
      });

  public function parseFile() {
    var ret:Array<FileRef> = [];
    while (true) 
      switch first(['@import', '//', '/*'], function (_) {}) {
        case Success('//'): upto('\n');
        case Success('/*'): upto('*/');
        case Success('@import'): upto('*/');
          allow('(reference)');
          expect('"');
          var arg = upto('"').sure();
          var name = arg.toString();
          if (name.startsWith('http:') || name.startsWith('https:')) {
            //TODO: figure out what to do
          }
          else ret.push({
            name: Path.join([Path.directory(fileName), name]),
            from: makePos(arg.start, arg.end),
          });
        default: break;
      };
    return ret;
  }
}
#end