
class Paths {

    macro public static function buildRouter(enm) {
        return macro function(steps : Array<String>) {
            return ${Steps.buildSwitchExprFromIdentifier(enm)}
        };
    }
    macro public static function buildParamParser(enm) {
        return ${Params.buildParamParser(enm)};
    }

}


