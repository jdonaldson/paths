
class Paths {
    public static macro function buildRoute(value:ExprOf<String>) {
        return null;
    }
    static function


	public static macro function toPath(value) {
		var en = switch Context.follow(Context.typeof(value)) {
			case TEnum(_.get() => en, _): en;
			case _: throw new Error("not an enum", value.pos);
		}

		var cases = new Array<Case>();

		for (ctorName in en.names) {
			var field = en.constructs[ctorName];
			var ctorIdent = macro $i{ctorName};
            var urlParts = [];
            var path_override = field.meta.has("path") ? {
                var k = field.meta.extract("path")[0];
                var path_expr = k.params[0].expr;
                var path = switch(path_expr){
                    case EConst(CString(str)) : {
                        str;
                    }
                    case _ : {
					    urlParts = [macro $v{ctorName}];
                        null;
                    }
                }
                path;
            } : null;
			switch field.type {
				case TEnum(_):
					cases.push({
						values: [ctorIdent],
						expr: macro $v{ctorName}
					});
				case TFun(args, _):
					var capturedNames = [];
					for (arg in args) {
                        switch Context.followWithAbstracts(arg.t){
                            case TInst(ct,[]) : {
                                var argIdent = macro $i{arg.name};
                                capturedNames.push(argIdent);
                                if (path_override == null){
                                    urlParts.push(macro $v{arg.name});
                                } else {
                                    urlParts.push(macro $v{path_override});
                                }
                            }
                            case TEnum(enm, []) :{
                                var argIdent = macro $i{arg.name};
                                capturedNames.push(argIdent);
                                if (path_override == null){
                                    urlParts.push(macro Paths.toPath($argIdent));
                                } else {
                                    urlParts.push(macro $v{path_override});
                                }
                            }
                            case _ : {
                            }
                        }
					}
                    var name = field.name;

					cases.push({
						values: [macro $ctorIdent($a{capturedNames})],
						expr: macro $v{name} +'/$' + $a{urlParts}.join("/$")
					});
				case _:
					throw "assert";
			}
		}

		return {
			pos: Context.currentPos(),
			expr: ESwitch(value, cases, null)
		};
ro}
}

    public static function buildPathSwitchCases2(en:EnumType) : Array<Case> {
        var cases : Array<Case> = [];
        for (name in en.names){
            var type = en.constructs[name].type;
            var k = buildFieldCaseValue(name, type);
            cases.push({
                values : [macro $k],
                expr : macro $v{name} + '/$' + $v{buildFieldCaseExpr(name, type)}
            });
        }
        return cases;
    }
