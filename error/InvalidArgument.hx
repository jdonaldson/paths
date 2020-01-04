package error;
class InvalidArgument extends InvalidParse {
    var arg_name : String;
    var enum_name : String;
    var enum_constructor_name : String;
    public function new(arg_name : String, enum_constructor_name : String, enum_name : String){
        this.arg_name = arg_name;
        this.enum_constructor_name = enum_constructor_name;
        this.enum_name = enum_name;
        super();
    }
}
