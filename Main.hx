typedef Boo = {hi : Int};
class Main {
    static function main(){
        // var router = Paths.buildRouter(Page);


        var router = Paths.buildRouter(Page);
        var param_parser = Paths.buildParamParser(TParams);
        var f = function(page : Page, params: TParams){
            switch [page, params] {
                case [Home, {hi:n}] : {
                    trace('yeo');
                    trace(n + " is the value for n");
                }
                default : trace("NO");
            }
        }
        var params = param_parser("foo=3&bar=2");
        var page = router(["Home"]);
        f(page,params);

        // var o = router(["Home"]);
        // trace(o + " is the value for o");

        // var p = router(["Foo","Baz", "1"]);
        // trace(p + " is the value for p");

        // var steps = "Scales/Guitar/Chromatic".split("/");

        // var q = router(steps);
        // trace(q + " is the value for q");

    }
}

typedef TParams = {
    ?hi : Int,
    ?ho : String
}


enum abstract Bar(String) from String to String {
   var Baz ='heeey';
   var Bing='hii';
   var Boo = 'hooo';
}



@:case_insensitive
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
