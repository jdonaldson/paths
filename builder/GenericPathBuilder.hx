package builder;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.TypeTools;
import haxe.macro.Context.currentPos as pos;

class GenericPathBuilder {
    public static function build() {
        var t = Context.getLocalType();
        var p = Context.signature(t);
        var class_name = 'PathParser_' + p;
        return switch t {
            case TInst(_, [tenum = TEnum(enm,[])]) : {
                var ctype =TypeTools.toComplexType(tenum);
                var expr =  buildSwitchFromType(tenum);
                var def = macro class $class_name {
                    var split : String;
                    public function new(split = "/") {
                        this.split = split;
                    }
                    public function parse(str:String) : $ctype {
                        var steps = str.split(this.split);
                        return ${expr};
                    }
                }
                haxe.macro.Context.defineType(def);
                return Context.getType(class_name);
            }
            default : {
                null;
            }
        }
    }

    public static function buildSwitchFromType(type:Type, optional=false, idx=0) : Expr {
        return switch type {
            case TEnum(enm, []) : {
                var enme = enm.get();
                var insensitive = enme.meta.has(":case_insensitive");
                var lower_case = enme.meta.has(":lower_case") || insensitive;

                var switched_expr = if (insensitive ){
                    macro steps[$v{idx++}].toLowerCase();
                } else {
                    macro steps[$v{idx++}];
                }
                var cases : Array<Case> = Lambda.map(enme.constructs, c-> {
                    return buildCaseFromEnumField(enme.constructs.get(c.name), idx);
                });
                cases.push(buildDefaultCase(optional));
                return {
                    expr : ESwitch(switched_expr, cases, null),
                    pos : pos()
                }
            }
			case _: {
                throw new Error("Not a valid enum", pos());
                return macro null;
            }
        }
    }


    public static function buildCaseFromEnumField(enmf: EnumField, idx=0) : Case {
        return switch enmf.type {
            case TEnum(enm, []) : {
                var enme  = enm.get();
                var names = [enme.module].concat(enme.pack).concat([enme.name, enmf.name]);
                var name = Context.parse(names.join("."), pos());

                return {
                    values : [macro $v{enmf.name}],
                    expr : macro ${name}
                }
            }
            case TFun(args, TEnum(enm,[])) : {
                var enme = enm.get();
                var names = [enme.module].concat(enme.pack).concat([enme.name, enmf.name]);
                var name = Context.parse(names.join("."), Context.currentPos());

                var arg_exprs = Lambda.map(args, a->{
                    return buildExprFromType(a.t, a.opt, idx++);
                });
                return {
                    values : [macro $v{enmf.name}],
                    expr : macro ${name}($a{arg_exprs})
                }
            }
            default : {
                throw new Error("Not a valid enum field", pos());
                return null;
            };
        };
    }

    public static function buildExprFromType(type : Type, optional=false, idx=0) : Expr {
        return switch type {
            case TEnum(_,[]) : buildSwitchFromType(type);
            case TAbstract(abs, []) if (abs.get().module == "StdTypes") : {
                switch (abs.get().name) {
                    case "String" : macro parser.CheckedParser.parseString(steps[$v{idx++}], $v{optional});
                    case "Int"    : macro parser.CheckedParser.parseInt(steps[$v{idx++}],    $v{optional});
                    case "Float"  : macro parser.CheckedParser.parseFloat(steps[$v{idx++}],  $v{optional});
                    case "Bool"   : macro parser.CheckedParser.parseBool(steps[$v{idx++}],   $v{optional});
                    default : {
                        throw new Error("Not a valid abstract type", pos());
                        macro null;
                    }
                }
            }
            case TAbstract(abs, []) : {
                var impl = abs.get().impl.get();
                return buildSwitchFromAbsImpl(impl, optional, idx);
            }
            default : {
                throw new Error("Not a valid type", pos());
                return macro null;
            };
        }
    }

    public static function buildDefaultCase(optional=false) : Case {
        var expr = !optional ?  macro throw new error.InvalidParse() : macro _;
        return {
            values : [macro _],
            expr : expr
        }
    }

    public static function buildSwitchFromAbsImpl(impl:ClassType, optional=false, idx=0) : Expr {
        var switched_expr = macro steps[$v{idx++}];
        var cases = Lambda.map(impl.statics.get(), s->{
            return {
                values : [macro $v{s.name}],
                expr : macro $i{s.name},
                guard : null
            };
        });
        cases.push(buildDefaultCase(optional));
        return {
            expr : ESwitch(switched_expr, cases, null),
            pos  : pos()
        };
    }

}
#end
