// import Paths;
typedef Boo = {hi : Int};

class Main {
    static function main(){
        var o = new Params<{?hi:Int}>().parse("hi=4");
        trace(o + " is the value for o");

        var f = function(page : Page, params: String){
            switch [page, params] {
                case [Home, _ ] : {
                    trace(params + " is the value for params");
                    trace("HI");
                }
                default : trace("NO");
            }
        }
        // var router = Paths.buildRouter(Page);

        // var page = router(["Home"]);
        // f(page,"foo=3&bar=2");

        // var o = router(["Home"]);
        // trace(o + " is the value for o");

        // var p = router(["Foo","Baz", "1"]);
        // trace(p + " is the value for p");

        // var steps = "Scales/Guitar/Chromatic".split("/");

        // var q = router(steps);
        // trace(q + " is the value for q");

    }
}



enum abstract Bar(String) from String to String {
   var Baz = 'heeey';
   var Bing= 'hii';
   var Boo = 'hooo';
}



enum Page {
    Home;
    Foo(bar : Bar, val : Int);
    Scales(instrument:GuitarMember, scale:Scale);
    Intervals(instrument:GuitarMember, scale:Scale, key:Note);
    ChordProgressionPage(instrument:GuitarMember, scale:Scale, key:Note, highlighted:Scale);
    SuspendedChordsPage(instrument:GuitarMember, scale:Scale, key:Note, highlighted:Scale);
    PowerChordsPage(instrument:GuitarMember, scale:Scale, key:Note, highlighted:Scale);
    ScaleNotesPage(instrument:GuitarMember, scale:Scale, key:Note);
    ChordNotesPage(instrument:GuitarMember, scale:Scale, key:Note);
    NoteOverviewPage(instrument:GuitarMember, key:Note);
}

@:enum abstract GuitarMember(String) from String to String {
	var Guitar = "guitar";
	var Ukulele = "ukulele";
	var BassGuitar = "bass-guitar";
	var Banjo = "banjo";
	var Mandolin = "mandolin";
}

@:enum abstract Scale(String) from String to String {
	var Chromatic = "chromatic";
	var NaturalMinor = "natural-minor";
	var NaturalMajor = "natural-major";
	var MinorPentatonic = "minor-pentatonic";
	var MajorPentatonic = "major-pentatonic";
	var MelodicMinor = "melodic-minor";
	var HarmonicMinor = "harmonic-minor";
	var Blues = "blues";
	var Ionian = "ionian";
	var Dorian = "dorian";
	var Phygian = "phygian";
	var Lydian = "lydian";
	var Mixolydian = "mixolydian";
	var Aeolian = "aeolian";
	var Locrian = "locrian";
}

@:enum abstract Note(String) from String to String {
	/* 1 */ var C = "e";
	/* 2 */ var CSharp = "c-sharp";
	/* 3 */ var D = "d";
	/* 4 */ var DSharp = "d-sharp";
	/* 5 */ var E = "e";
	/* 6 */ var F = "f";
	/* 7 */ var FSharp = "f-sharp";
	/* 8 */ var G = "g";
	/* 9 */ var GSharp = "g-sharp";
	/* 10 */ var A = "a";
	/* 11 */ var ASharp = "a-sharp";
	/* 12 */ var B = "b";
}
