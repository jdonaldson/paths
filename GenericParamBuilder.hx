#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Context.currentPos as pos;

class GenericParamBuilder {

    public static function parseType(type : Type, opt = false) : Expr {
        return switch type {
            case TAbstract(_.get().name => "Null", [type = TAbstract(_,[])]) : {
                return parseType(type, true);
            }
            case TAbstract(abs, []) if (abs.get().module == "StdTypes") : {
                switch abs.get().name {
                    case "Int"    : macro CheckedParser.parseInt(pair[1], $v{opt});
                    case "String" : macro CheckedParser.parseString(pair[1], $v{opt});
                    case "Float"  : macro CheckedParser.parseFloat(pair[1], $v{opt});
                    case "Bool"   : macro CheckedParser.parseBool(pair[1], $v{opt});
                    default : {
                        throw new Error("Not a valid abstract type", pos());
                        macro null;
                    }
                }
            }
            default : {
                throw new Error("Not a valid abstract type", pos());
                macro null;
            }
        }

    }
    public static function build() {
        var t = Context.getLocalType();
        switch t {
            case TInst(_,[ttanon=TAnonymous(tanon)]) : {
                var cases = Lambda.map(tanon.get().fields, f->{
                    var parseExpr = parseType(f.type);
                    return {
                        values  : [macro $v{f.name}],
                        expr : macro Reflect.setField(obj, pair[0], $parseExpr),
                        guard : null
                    }
                });

                var switch_expr : Expr = {
                    expr : ESwitch(macro pair[0], cases, null),
                    pos : Context.currentPos()
                }
                var p = Context.signature(t);
                var class_name = 'ParamParser_' + p;
                var ctype = haxe.macro.TypeTools.toComplexType(ttanon);

                var def = macro class $class_name {
                    var sep : String;
                    var pair_sep : String;
                    public function new(separator = "&", pair_separator = "="){
                        this.sep = separator;
                        this.pair_sep = pair_separator;
                    }
                    public function parse(str:String) : $ctype {
                        var obj = {};
                        for (item in str.split(this.sep)){
                            var pair = item.split(this.pair_sep);
                            ${switch_expr};
                        }
                        return cast obj;
                    }
                }
                haxe.macro.Context.defineType(def);
                return Context.getType(class_name);

            }
            default : null;
        }
        return t;
    }

}
#end
