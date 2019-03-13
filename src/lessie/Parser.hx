package lessie;

#if macro
import tink.parse.Char.*;
import tink.parse.*;
import haxe.io.Path;
using StringTools;
using tink.CoreApi;
import haxe.macro.Expr;

class Parser extends ParserBase<Position, Error> {
  var fileName:String;
  
  public function new(fileName, source) {
    super(source, Reporter.expr(this.fileName = fileName));
  }

  override function doSkipIgnored() 
    doReadWhile(WHITE);

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