package lessie;

import haxe.macro.Context;
import sys.FileSystem;
import haxe.macro.Type;
import haxe.macro.Expr;
import sys.io.File;
using haxe.io.Path;

class Builder {
  
  static var oldInfos = new Map<String, Info>();
  var newInfos = new Map<String, Info>();
  var mtimes = new Map<String, Int>();
  var found = new Array<FileRef>();
  
  var mustBuild = false;
  
  public function new() { }
  
  
  function doBuild()
    Less.build([for (f in found) f.name], Lessie.getOutputPath());
    
  public function buildLess(types:Array<Type>) {
    
    Context.onAfterGenerate(function () {
      for (t in types)
        switch t {
          case TInst(c, _): getLess(c);
          case TEnum(e, _): getLess(e);
          case TAbstract(a, _): getLess(a);
          default:
        }
      
      #if forceLessie
        doBuild();
      #else
      for (f in found)
        getInfo(f);
      
      if (mustBuild) 
        doBuild();
      #end

      oldInfos = newInfos;
      
    });
    
  }
  
  function mtime(file:FileRef) {
    if (!mtimes.exists(file.name))
      mtimes[file.name] = try {
        Std.int(FileSystem.stat(file.name).mtime.getTime() / 1000);
      }
      catch (e:Dynamic) {
        Context.error('Cannot open file ${file.name}', file.from);
      }
      
    return mtimes[file.name];
  }
  
  function getLess<T:BaseType>(r:Ref<T>) {
    var t = r.get();
    
    if (t.meta.has(':used'))
      for (m in t.meta.extract(':less')) 
        for (p in m.params)
          switch p.expr {
            case EConst(CString(s)):
              
              found.push({ 
                name: Path.join([Path.directory(Context.getPosInfos(t.pos).file), s]), 
                from: p.pos
              });
              
            default:
              
              Context.error('Parameter must be string constant', p.pos);
          }
      
    
    return null;
  }
  
  function readInfo(file:FileRef):Info {
    
    mustBuild = true;
    
    return {
      mtime: mtime(file),
      dependencies: Less.parse(File.getContent(file.name), file.name).dependencies,
    };
  }
  
  function getInfo(file:FileRef) {
    if (!newInfos.exists(file.name)) {
      newInfos[file.name] = switch oldInfos[file.name] {
        case null:
          readInfo(file);
        case stale if (stale.mtime < mtime(file)):
          readInfo(file);
        case v: v;
      }
      
      for (dep in newInfos[file.name].dependencies)
        getInfo(dep);
    }
    
    return newInfos[file.name];
  }
  
}