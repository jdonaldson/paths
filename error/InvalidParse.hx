package error;
class InvalidParse extends Error {
    public function new() {
        super();
        this.message = "InvalidParse";
    }
}
