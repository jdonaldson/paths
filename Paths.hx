import haxe.macro.Expr;

class Paths {

    macro public static function buildRouter(enm : Expr) : Expr {
        return macro function(steps : Array<String>) {
            return ${Steps.buildSwitchExprFromIdentifier(enm)}
        };
    }

}


