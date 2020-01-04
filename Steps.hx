#if macro
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Context.currentPos as pos;

class Steps {


    public static function buildDefaultCase(optional=false) : Case {
        var expr = !optional ?  macro throw new error.InvalidParse() : macro _;

        return {
            values : [macro _],
            expr : expr
        }
    }

    public static function buildExprFromType(type : Type, optional=false, idx=0) : Expr {
        return switch type {
            case TEnum(_,[]) : buildSwitchFromType(type);
            case TAbstract(abs, []) if (abs.get().module == "StdTypes") : {
                switch (abs.get().name) {
                    case "String" : macro CheckedParser.parseString(steps[$v{idx++}], $v{optional});
                    case "Int"    : macro CheckedParser.parseInt(steps[$v{idx++}],    $v{optional});
                    case "Float"  : macro CheckedParser.parseFloat(steps[$v{idx++}],  $v{optional});
                    case "Bool"   : macro CheckedParser.parseBool(steps[$v{idx++}],   $v{optional});
                    default : {
                        throw new Error("Not a valid abstract type", pos());
                        macro null;
                    }
                }
            }
            case TAbstract(abs, []) : {
                var impl = abs.get().impl.get();
                buildSwitchFromAbsImpl(impl, optional, idx);
            }
            default : {
                throw new Error("Not a valid type", pos());
                return macro null;
            };
        }
    }

    public static function buildCaseFromEnumField(enmf: EnumField, idx=0) : Case {
        return switch enmf.type {
            case TEnum(enm, []) : {
                return {
                    values : [macro $v{enmf.name}],
                    expr : macro $i{enmf.name}
                }
            }
            case TFun(args, ret) : {
                var arg_exprs = Lambda.map(args, a->{
                    return buildExprFromType(a.t, a.opt, idx++);
                });

                return {
                    values : [macro $v{enmf.name}],
                    expr : macro $i{enmf.name}($a{arg_exprs})
                }
            }
            default : {
                throw new Error("Not a valid enum field", pos());
                return null;
            };
        };
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

    public static function buildSwitchFromType(type:Type, optional=false, idx=0) : Expr {
        return switch type {
            case TEnum(enm, []) : {
                var enme = enm.get();
                var insensitive = enme.meta.has(":case_insensitive");
                var lower_case = enme.meta.has(":lower_case") || insensitive;

                var switched_expr = if (insensitive ){
                    macro steps[$v{idx++}];
                } else {
                    macro steps[$v{idx++}].toLowerCase();
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

    public static function buildSwitchExprFromIdentifier(expr:Expr, idx=0) : Expr {
        return switch expr.expr{
            case EConst(CIdent(val)) : buildSwitchFromType(Context.getType(val));
			case _: throw new Error("Not a valid identifier", pos());
        }
    }
}
#end
