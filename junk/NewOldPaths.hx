
class Paths {




    macro public static function buildRouter(enm : Expr) : Expr {
        enumConstructs(enm);
        var b = macro null;
        var eswitch = buildSwitchExpr(enm, 0);

        var k = macro function(paths : Array<String>) {
            return $eswitch;
        };
        return k;
        // return macro null;
    }

    macro public static function switchPath(value:Expr) : Expr {
        var en : EnumType = extractEnumType(value);
        var cases = buildPathSwitchCases(en);

        // return {
        //     pos : Context.currentPos(),
        //     expr : ESwitch(value, cases, null)
        // }
        return macro null;
    }

    macro public static function foo(value:Expr) : Expr {
        return value;
    }




#if macro

    public static function enumConstructs(enm : Expr ) : Array<Path> {
        return switch enm.expr {
            case EConst(CIdent(val)) : {
                switch Context.getType(val) {
                    case TEnum(enm,[]) : {
                        var constructs = enm.get().constructs;
                        var paths = [];
                        for (c in constructs){
                            switch c.type {
                                case TEnum(enm, []) : {
                                    paths.push({
                                        name : c.name,
                                        path_str : c.name,
                                        convert : None,
                                        children : []
                                    });

                                }
                                case TFun(_) : {}
                                default : {};

                            }
                        }

                        null;
                    }
                    case TAbstract(abs,[]) : {
                        var statics = abs.get().impl.get().statics.get();
                        for (s in statics){
                            trace(s.name + " is the value for s.name");
                        }
                        null;
                    }
                    case _ : {
                        null;
                    }
                }
            }
            case _ : null;
        }
    }

    public static function buildFieldCaseValue(name, type) : Expr {
        switch type {
            case TEnum(_) : return macro $i{name}
            case TFun(args,_) : {
                var idents = args.map(arg->{
                    return macro $i{arg.name}
                });
                return macro null;
                // return macro $i{name}($a{idents});
            }
			case _: throw new Error("not an enum", pos());

        }
    }

    public static function buildFieldCaseExpr(name : String, type : Type) : String {
        var ret = '';
        switch follow(type) {
            case TEnum(_) : ret = name;
            case TInst(c, _) : ret = name;
            case TFun(args ,_) : {
                return args.map(arg->{
                    return buildFieldCaseExpr(arg.name, arg.t);
                }).join("/$");
            }
            case _ : {
            }
        }
        return ret;
    }



    static function isAbstractEnum(type:Type) : Bool {
        return switch type {
            case TAbstract(abs,[]) : {
                abs.get().meta.has(':enum');
            }
            case _ : false;
        }
    }

    static function buildSwitchExpr(enm : Expr, idx = 0) : Expr {
        var cases : Array<Case> = [];
        switch enm.expr {
            case EConst(CIdent(val)) : {
                switch Context.getType(val) {
                    case TEnum(enm,[]) : {
                        var constructs = enm.get().constructs;
                        for (c in constructs){
			                var ctorIdent = macro $i{c.name};
                            switch c.type {
                                case TEnum(_,_) : {
                                    cases.push({
                                        values : [macro $v{c.name}],
                                        expr : {
                                            macro ${ctorIdent};
                                        }
                                    });
                                }
                                case TFun(args,_) :  {
                                    var ctor_args = [];
                                    for (aidx in 0...args.length){
                                        var arg = args[aidx];
                                        var abstract_cases = [];
                                        switch arg.t{
                                            case TAbstract(abs, []) : {
                                                if (abs.get().impl != null){
                                                    var impl = abs.get().impl.get();
                                                    if (impl.meta.has(':enum')){
                                                        for (s in impl.statics.get()){
                                                            var expr = s.meta.extract(':value')[0].params[0].expr;
                                                            switch  expr   {
                                                                case ECast({pos : _ , expr : EConst(CString(str, quotes))}, null) : {
                                                                    abstract_cases.push({
                                                                        values : [macro $v{s.name}],
                                                                        expr :  macro $i{s.name}
                                                                    });
                                                                }
                                                                case _ : {

                                                                }
                                                            }
                                                        }

                                                        var default_case = {
                                                            values : [macro _],
                                                            expr : macro null
                                                        }
                                                        ctor_args.push({
                                                            expr : {
                                                                expr : ESwitch( macro paths[$v{idx}], abstract_cases, null),
                                                                pos : Context.currentPos()
                                                            },
                                                            pos : Context.currentPos()
                                                        });

                                                    }
                                                } else {
                                                    trace("WHAAAAA");
                                                }
                                            }
                                            // case TInst(_.get().name => "String", []) : {
                                            //     ctor_args.push(macro paths[$v{aidx + idx}]);
                                            // }
                                            // case TAbstract(_.get().name => "Int",[]) : {
                                            //     ctor_args.push(macro Std.int(paths[$v{aidx + idx}]));
                                            // }
                                            // case TAbstract(_.get().name => "Float",[]) : {
                                            //     ctor_args.push(macro Std.float(paths[$v{aidx + idx}]));
                                            // }
                                            // case TAbstract(_.get().name => "Bool",[]) : {
                                            //     ctor_args.push(macro Std.float(paths[$v{aidx + idx}]));
                                            // }
			                                case _: throw new Error("Not a value type", c.pos);
                                        }
                                    }
                                    cases.push({
                                        values : [macro $v{c.name}],
                                        expr : {
                                            macro ${ctorIdent}($a{ctor_args});
                                        }
                                    });
                                }
			                    case _: throw new Error("not an enum", c.pos);
                            }
                        }
                    }
			        case _: throw new Error("not an enum", enm.pos);
                }
            }
			case _: throw new Error("not an enum", enm.pos);

        }
        var default_case = {
            values : [macro _],
            expr : macro null
        }
        cases.push(default_case);
        var eswitch = {
            expr : ESwitch(macro paths[$v{idx}], cases, null),
            pos : Context.currentPos()
        }
        return eswitch;
    }


    public static function buildPaths( field : EnumField, paths : Array<Dynamic>) {
        switch field.type {
            case TEnum(_) : paths.push(field.name);
            case TFun(args, _) : {
                var path_str = '';
                var curpath = field.name;
                var curpaths = [curpath];
                for (arg in args){
                    switch arg.t {
                        case TAbstract(abs,[]) : {
                            if (abs.get().meta.has(':enum')){
                                var statics = abs.get().impl.get().statics.get();
                                var stat = statics[0];
                                // trace(stat.meta.get()[0].params[0].expr + " is the value for stat");
                            }
                        }
                        case _ : {
                            trace('yo');
                        }
                    }
                    switch follow(arg.t){
                        case TAbstract(_.toString() => 'Int', []) : {
                            // trace("int");
                            for (idx in 0...curpaths.length){
                                curpaths[idx]+= '/${arg.name}_int';
                            }
                        }
                        case TAbstract(_.toString() => 'String', []) : {
                            trace("string");
                            for (idx in 0...curpaths.length){
                                curpaths[idx]+= '/${arg.name}_string';
                            }
                        }
                        case TEnum(enm, []) : {
                            trace("enum");
                            var en = enm.get();
                            var newpaths = [];
                            for (name in  en.names){
                                var field = en.constructs[name];
                                buildPaths(field, newpaths);
                            }
                            var buildpaths = [];
                            for (curpath in curpaths){
                                for(newpath in newpaths){
                                    buildpaths.push(curpath + '/' + newpath);
                                }
                            }
                            curpaths = buildpaths;

                        }
                        case _ : {
                            // trace(Context.follow(follow(arg.t)));
                            // trace("HI");
                        }
                    }
                }
                for (path in curpaths){
                    paths.push(path);
                }

            }
            case _ : {
                trace("YOOO");
            }
        }
    }
    public static function buildPathSwitchCases(en:EnumType) : Array<Case> {
        var paths  = [];
        for (name in en.names){
            var field = en.constructs[name];
            buildPaths(field, paths);
        }
        // trace(paths + " is the value for paths");
        return null;
    }


    //----------------------------------------------


    public static function extractEnumType(value:Expr) : EnumType {
		switch Context.follow(Context.typeof(value)) {
			case TEnum(_.get() => en, _): return en;
			case _: throw new Error("not an enum", value.pos);
		}
    }



#end
}


enum Convert {
    None;
    Float;
    Int;
    Bool;
    AbstractString;
}

typedef Path = {
    name : String,
    path_str : String,
    convert : Convert,
    children : Array<Path>
}




