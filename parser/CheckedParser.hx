package parser;
import error.InvalidParse;

class CheckedParser {
    public function new(){}

    public function parseInt(arg:String, optional=false) : Int {
        var res = Std.parseInt(arg);
        if (res == null && !optional){
            throw new InvalidParse();
        } else {
            return res;
        }
    }

    public function parseFloat(arg:String, optional=false) : Float {
        var res = Std.parseFloat(arg);
        if (res == null && !optional){
            throw new InvalidParse();
        } else {
            return res;
        }
    }

    public function parseBool(arg:String, optional=false) : Bool {
        var res = Std.parseFloat(arg);
        if (res == null && !optional){
            throw new InvalidParse();
        } else {
            return res > 0 || res < 0;
        }
    }
    public function parseString(arg:String, optional=false, url_decode = true) : String {
        if (arg == null && !optional){
            throw new InvalidParse();
        } else {
            return url_decode ? StringTools.urlDecode(arg) : arg;
        }
    }

}
