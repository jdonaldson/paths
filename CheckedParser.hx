import error.InvalidParse;

class CheckedParser {

    public static function parseInt(arg:String, optional=false) : Int {
        var res = Std.parseInt(arg);
        if (res == null && !optional){
            throw new InvalidParse();
        } else {
            return res;
        }
    }

    public static function parseFloat(arg:String, optional=false) : Float {
        var res = Std.parseFloat(arg);
        if (res == null && !optional){
            throw new InvalidParse();
        } else {
            return res;
        }
    }

    public static function parseBool(arg:String, optional=false) : Bool {
        var res = Std.parseFloat(arg);
        if (res == null && !optional){
            throw new InvalidParse();
        } else {
            return res > 0 || res < 0;
        }
    }
    public static function parseString(arg:String, optional=false) : String {
        if (arg == null && !optional){
            throw new InvalidParse();
        } else {
            return arg;
        }
    }

}
