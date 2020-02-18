package parser;
import Error;

class CheckedParser {
    public function new(){}

    public function parseInt(arg:String, optional=false) : Int {
        var res = Std.parseInt(arg);
        if (res == null && !optional){
            throw InvalidParse;
        } else {
            return res;
        }
    }

    public function parseFloat(arg:String, optional=false) : Float {
        var res = Std.parseFloat(arg);
        if (res == null && !optional){
            throw InvalidParse;
        } else {
            return res;
        }
    }

    public function parseBool(arg:String, optional=false) : Bool {
        var res = Std.parseFloat(arg);
        if (res == null && !optional){
            throw InvalidParse;
        } else {
            return res > 0 || res < 0;
        }
    }
    public function parseString(arg:String, optional=false, url_decode = true) : String {
        if (arg == null && !optional){
            throw InvalidParse;
        } else {
            return url_decode ? StringTools.urlDecode(arg) : arg;
        }
    }
    public function parseInt64(arg:String, optional=false) : haxe.Int64 {
        if (arg == null && !optional) {
            throw InvalidParse;
        } else {
            return haxe.Int64.parseString(arg);
        }
    }

    public function basicRender(arg:Dynamic, optional=false) : String {
        return (arg == null && optional) ? '' : Std.string(arg);
    }

    inline public function renderInt(arg:Int, optional=false) : String {
        return basicRender(arg, optional);
    }

}
