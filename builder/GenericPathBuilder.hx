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
                var path_expr = buildPathExprFromType(tenum);
                var def = macro class $class_name implements ParseBase<$ctype>{
                    var split : String;
                    var parser : parser.CheckedParser;
                    public function new(split = "/", ?parser : parser.CheckedParser) {
                        this.split = split;
                        if (parser == null)  parser = new parser.CheckedParser();
                        this.parser = parser;

                    }
                    public function parse(str:String) : $ctype {
                        var steps = str.split(this.split);
                        return ${expr};
                    }
                    public function toPath(path:$ctype) : String {
                        return ${path_expr};
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
                    case "String" : macro this.parser.parseString(steps[$v{idx++}], $v{optional});
                    case "Int"    : macro this.parser.parseInt(steps[$v{idx++}],    $v{optional});
                    case "Float"  : macro this.parser.parseFloat(steps[$v{idx++}],  $v{optional});
                    case "Bool"   : macro this.parser.parseBool(steps[$v{idx++}],   $v{optional});
                    default : {
                        throw new Error("Not a valid abstract type", pos());
                        macro null;
                    }
                }
            }
            case TAbstract(abs, []) if (abs.get().module == "haxe.Int64") : {
                macro this.parser.parseInt64(steps[$v{idx++}], $v{optional});
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
        var cases  : Array<Case> = Lambda.map(impl.statics.get(), s->{
            var const_expr : Expr = switch s.meta.extract(":value")[0].params[0].expr {
                case ECast(expr, null) : expr;
                default : null;
            };
            return {
                values : [const_expr],
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

    //
    // to-path-oriented methods:
    //


    public static function buildPathExprFromType(type : Type) : Expr {
        var en:EnumType = switch Context.follow(type) {
            case TEnum(_.get() => en, _): en;
            case _: throw new Error("not an enum", Context.currentPos());
        }

        var cases:Array<Case> = [];
        for (ctorName in en.names) {
            var field:EnumField = en.constructs[ctorName];
            var ctorIdent:Expr = macro $i{ctorName};
            var urlParts:Array<Expr> = [macro $v{ctorName}];
            if (field.meta.extract("catchrest").length > 0) {
                urlParts = [];
            }

            var path_override:String = detectOverridePath(field, ctorName, urlParts);
            switch (field.type) {
                case TEnum(_):
                    cases.push({
                        values: [ctorIdent],
                        expr: macro $v{ctorName}
                    });
                case TFun(args, _):
                    var capturedNames:Array<Expr> = [];
                    for (arg in args) {
                        argsToPath(arg, path_override, urlParts, capturedNames);
                    }
                    cases.push({
                        values: [macro $ctorIdent($a{capturedNames})],
                        expr: macro $a{urlParts}.join("/")
                    });
                case _:
                    throw "assert";
            }
        }

        return {
            pos: Context.currentPos(),
            expr: ESwitch(macro path, cases, null)
        };
    }

	private static function argsToPath(arg:{name:String, opt:Bool, t:Type}, path_override:String, urlParts:Array<Expr>, capturedNames:Array<Expr>) {
		switch (Context.follow(arg.t)) {
			case TInst(ct, []):
				var argIdent:Expr = macro $i{arg.name};
				capturedNames.push(argIdent);
				urlParts.push(pathWithOverride(path_override, $v{argIdent}));
			case TEnum(enm, []):
				var argIdent:Expr = macro $i{arg.name};
				capturedNames.push(argIdent);
				urlParts.push(pathWithOverride(path_override, macro PathRouter.toPath($argIdent)));
			case TAbstract(abstr, []) if (abstr.get().module == "StdTypes"):
				var argIdent:Expr = macro $i{arg.name};
				capturedNames.push(argIdent);
				var argIdent:Expr = switch (abstr.get().name) {
					case "String" : macro ${argIdent};
					case "Int"    : macro Std.string(${argIdent});
					case "Float"  : macro Std.string(${argIdent});
					default       : macro null;
				}
				if (argIdent != null) {
					urlParts.push(pathWithOverride(path_override, argIdent));
				}
			case TAbstract(abstr, []):
				var argIdent:Expr = macro $i{arg.name};
				capturedNames.push(argIdent);
				var impl:ClassType = abstr.get().impl.get();
				var argIdent:Expr = switch (impl.module) {
					case "haxe.Int64":
						macro Int64.toStr(${argIdent});
					default:
						macro ${argIdent};
				};
				urlParts.push(pathWithOverride(path_override, argIdent));
			case _:
		}
	}

	private static function detectOverridePath(field:EnumField, ctorName:String, urlParts:Array<Expr>):String {
		if (field.meta.has("path")) {
			var k:MetadataEntry = field.meta.extract("path")[0];
			var path_expr:ExprDef = k.params[0].expr;
			return switch (path_expr) {
				case EConst(CString(str)):
					str;
				case _:
					urlParts = [macro $v{ctorName}];
					null;
			}
		};
		return null;
	}
	private static function pathWithOverride(path_override:String, argIdent:Expr):Expr {
		if (path_override == null) {
			return argIdent;
		} else {
			return macro $v{path_override};
		}
	}

}
#end
