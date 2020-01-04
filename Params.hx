#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Context.currentPos as pos;
import haxe.macro.Context.followWithAbstracts as follow;

class Params {
    public static function buildFieldParserFromType(type : Type) : Expr {
        return macro null;
    }
    public static function buildFieldSetterFromType(type:Type) : Expr {
        switch type {
            case TType(_.get().type => TAnonymous(tanon), []) : {
                for (field in tanon.get().fields) {
                    var t = follow(field.type);
                    switch t {
                        case TAbstract(abs, []) if (abs.get().module == "StdTypes") : {
                            var optional = field.meta.has(":optional");
                            switch(abs.get().name) {
                                case "Int"    : macro Reflect.setField(result, paths[1], CheckedParser.parseInt(steps[paths[1]],    $v{optional}));
                                case "Float"  : macro Reflect.setField(result, paths[1], CheckedParser.parseFloat(steps[paths[1]],  $v{optional}));
                                case "Bool"   : macro CheckedParser.parseBool(steps[paths[1]],   $v{optional});
                                case _ : {
                                    throw new Error("Not a valid field type", pos());
                                    return macro null;
                                }
                            }
                        }
                        case TInst(t, []) : {
                                var optional = field.meta.has(":optional");
                                macro Reflect.setField(result, paths[1], CheckedParser.parseString(steps[paths[1]],    $v{optional}));
                        }
                        case _ : {
                            throw new Error("Not a valid field type", pos());
                            return macro null;
                        }
                    }
                    macro Reflect.setField(result, pair[0], null);

                }
            }
			case _: {
                throw new Error("Not a valid typedef", pos());
                return macro null;
            }
        }
        return macro null;
    }


    public static function buildParamParser(tdef:Expr) : Expr {
        var type = switch tdef.expr {
            case EConst(CIdent(val)) : Context.getType(val);
			case _: throw new Error("Not a valid identifier", pos());
        }
        var ctype = haxe.macro.TypeTools.toComplexType(type);

        return macro function(str:String) : $ctype {
            var result : $ctype = {};
            for (item in str.split("&")) {
                var pair = item.split("=");
                trace("HI");
                ${buildFieldSetterFromType(type)}
            }
            return result;
        }
    }
}
#end
