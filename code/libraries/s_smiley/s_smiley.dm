/////////////////////////////////////////////////////////////////////
// Spuzzum's Imbedded Smileys Library   by Jeremy "Spuzzum" Gibson //
/////////////////////////////////////////////////////////////////////
/*
Just include this library and its accompanying icon, s_smileys.dmi
in your project.  Then, whenever you send output to players, instead
of using

  usr << "Blah blah blah! =)"

you can imbed the smileys using

  usr << s_smileys( "Blah blah blah! =)" )


In other words, any text you make, rather than

  usr << text

use

  usr << s_smileys(text)


That's all there is to it!  Have a nice day. ;-)


(Personally, I rather dislike having my text replaced with pictures.
But Tom wanted (rather, demanded ;-) this library, so I made it. =)


Contributors:
  Deadron <ron@deadron.com> - for the dd_replacetext() proc
  	and supportive functions dd_text2list() and dd_list2text()

*/

/*****************************************************************************

The replacetext proc is a snippet of code I created from scratch some time ago
to be a method that doesn't involve lengthy parsing and then deparsing of a
text string.  It is contained in replacetext.dm.  If you get an error related
to 'duplicate proc definition', just exclude that file from this library by
removing its checkbox.

*****************************************************************************/

world/New()
	..()
	spawn()
		var/L[0] //originally added typesof(/smiley) but the order was messed
		for(var/S in typesof(/smiley)-/smiley)
			L += S
		var/A
		for(A in L)
			s_smileys += new A


var/s_smileys[0]

smiley
	var
		smileys[]
		iconstate

	//Allows s_smiley to work on HTML-encoded strings
	New()
		..()
		for(var/smiley in smileys)
			var/new_string = replacetext( replacetext(smiley, "<", "&lt;"), ">", "&gt;" )
			if(!cmptext(new_string, smiley))
				smileys += new_string

	surprised_thoughtful_wink
		smileys = list("<;|","<;-|","<;^|", "<;o|")
		iconstate = "surprised/thoughtful wink"

	sadistic
		smileys = list(">=)",">:)",">:-)",">=-)",">=^)",">:^)",">=\]",">:\]",">:-\]",
			">=-\]",">=^\]",">:^\]",">:>",">:->",">=->",">=^>",">:^>",">=o>",">:o>",
			">=o)",">:o)",">=o\]",">:o\]")
		iconstate = "sadistic"
	surprised
		smileys = list("<=)","<:)","<:-)","<=-)","<=^)","<:^)","<=\]","<:\]","<:-\]",
			"<=-\]","<=^\]","<:^\]","<:>","<:->","<=->","<=^>","<:^>","<=o>","<:o>",
			"<=o)","<:o)","<=o\]","<:o\]")
		iconstate = "surprised"
	angry
		smileys = list(">=(",">:(",">:-(",">=-(",">=^(",">:^(",">=\[",">:\[",">:-\[",
			">=-\[",">=^\[",">:^\[",">:<",">:-<",">=-<",">=^<",">:^<",">=o<",">:o<",
			">=o(",">:o(",">_<",">.<",">o<")
		iconstate = "angry"
	sad_b
		smileys = list("<=(","<:(","<:-(","<=-(","<=^(","<:^(","<=\[","<:\[","<:-\[",
			"<=-\[","<=^\[","<:^\[","<:<","<:-<","<=-<","<=^<","<:^<","<:o\[","<:o(",
			"<=o\[","<=o(")
		iconstate = "sad_b"
	crying_b
		smileys = list("<=.(","<:.(","<:.-(","<=.-(","<=.^(","<:.^(","<=.\[","<:.\[","<:.-\[",
			"<=.-\[","<=.^\[","<:.^\[","<:.<","<:.-<","<=.-<","<=.^<","<:.^<","<:.o\[","<:.o(",
			"<=.o\[","<=.o(","<=,(","<:,(","<:,-(","<=,-(","<=,^(","<:,^(","<=,\[","<:,\[","<:,-\[",
			"<=,-\[","<=,^\[","<:,^\[","<:,<","<:,-<","<=,-<","<=,^<","<:,^<","<:,o\[","<:,o(",
			"<=,o\[","<=,o(","<=\'(","<:\'(","<:\'-(","<=\'-(","<=\'^(","<:\'^(","<=\'\[","<:\'\[","<:\'-\[",
			"<='-\[","<='^\[","<:'^\[","<:'<","<:'-<","<='-<","<='^<","<:'^<","<:'o\[","<:'o(",
			"<=\'o\[","<=\'o(","<=*(","<:*(","<:*-(","<=*-(","<=*^(","<:*^(","<=*\[","<:*\[","<:*-\[",
			"<=*-\[","<=*^\[","<:*^\[","<:*<","<:*-<","<=*-<","<=*^<","<:*^<","<:*o\[","<:*o(",
			"<=*o\[","<=*o(")
		iconstate = "crying_b"
	mad_tongue
		smileys = list(">=P",">:P",">:oP",">:-P",">=-P",">=^P",">:^P",">:oP",">=oP")
		iconstate = "mad/tongue"
	mad_tongue2
		smileys = list(">=p",">:p",">:-p",">=-p",">=^p",">:^p",">=þ",">:þ",">:-þ",
			">=-þ",">=^þ",">:^þ",">=op",">:op",">=oþ",">:oþ")
		iconstate = "mad/tongue2"
	sigh_tongue2
		smileys = list("<=p","<:p","<:-p","<=-p","<=^p","<:^p","<=þ","<:þ","<:-þ",
			"<=-þ","<=^þ","<:^þ","<=op","<:op","<=oþ","<:oþ")
		iconstate = "sigh/tongue2"
	sigh_tongue
		smileys = list("<=P","<:P","<:-P","<=-P","<=^P","<:^P","<=oP","<:oP")
		iconstate = "sigh/tongue"
	evil_grin
		smileys = list(">=D",">:D",">:-D",">=-D",">=^D",">:^D")
		iconstate = "evil grin"
	worried_grin
		smileys = list("<=D","<:D","<:-D","<=-D","<=^D","<:^D")
		iconstate = "worried grin"
	naughty_wink
		smileys = list(">;)",">;-)",">;^)",">;\]",">;-\]",">;^\]",">;>",">;->",">;^>",">;o>",
			">;o)")
		iconstate = "naughty wink"
	surprised_wink
		smileys = list("<;)","<;-)","<;^)","<;\]","<;-\]","<;^\]","<;>","<;->","<;^>","<;o>",
			"<;o)")
		iconstate = "surprised wink"
	angry_wink
		smileys = list(">;(",">;-(",">;^(",">;\[",">;-\[",">;^\[",">;<",">;-<",">;^<",">;o<",
			">;o(")
		iconstate = "angry wink"
	sad_wink_b
		smileys = list("<;(","<;-(","<;^(","<;\[","<;-\[","<;^\[","<;<","<;-<","<;^<",
			"<;o<")
		iconstate = "sad wink_b"
	sad_wink_tongue2
		smileys = list("<;p","<;-p","<;^p","<;þ","<;-þ","<;^þ","<;oþ","<;op")
		iconstate = "sad wink/tongue2"
	sad_wink_tongue
		smileys = list("<;P","<;-P","<;^P","<;oP")
		iconstate = "sad wink/tongue"
	angry_thoughtful_wink
		smileys = list(">;|",">;-|",">;^|",">;o|")
		iconstate = "angry/thoughtful wink"
	skeptical
		smileys = list(">=|",">:|",">:-|",">=-|",">=^|",">:^|",,">=o|",">:o|")
		iconstate = "skeptical"
	confused
		smileys = list("<=|","<:|","<:-|","<=-|","<=^|","<:^|","<=o|","<:o|")
		iconstate = "confused"
	angry_wink_tongue2
		smileys = list(">;p",">;-p",">;^p",">;þ",">;-þ",">;^þ",">;oþ",">;op")
		iconstate = "angry wink/tongue2"
	angry_wink_tongue
		smileys = list(">;P",">;-P",">;^P",">;oP")
		iconstate = "angry wink/tongue"
	angry_uncertain
		smileys = list(">:/",">:\\",">=/",">=\\",">:o\\",">:o/",">=^/",">=^\\",">:^/",">:^\\",
			">=-/",">=-\\",">:-/",">:-\\")
		iconstate = "angry/uncertain"
	frustrated
		smileys = list(">=o",">:o",">:-o",">=-o",">=^o",">:^o",">=O",">:O",">:-O",
			">=-O",">=^O",">:^O",">=oO",">:oO")
		iconstate = "frustrated"
	naughty_wink_grin
		smileys = list(">;D",">;-D",">;^D",">;oD")
		iconstate = "naughty wink/grin"
	sheepish_wink_grin
		smileys = list("<;D","<;-D","<;^D","<;oD")
		iconstate = "sheepish wink/grin"
	surprised_b
		smileys = list("<=o","<:o","<:-o","<=-o","<=^o","<:^o","<=O","<:O","<:-O",
			"<=-O","<=^O","<:^O","<=oO","<:oO")
		iconstate = "surprised_b"
	angry_weird
		smileys = list(">:S",">=S",">=oS",">:oS",">:-S",">=-S",">:^S",">=^S",">:oS",">=oS",
			">=}",">={",">:}",">:{",">:@",">:?",">=?",">:-?",">=-?",">:^?",">=^?",">:o?",">=o?",
			">:$",">=$",">:-$",">=-$",">:^$",">=^$",">:o$",">=o$")
		iconstate = "angry/weird"
	sad_weird
		smileys = list("<:S","<=S","<=oS","<:oS","<:-S","<=-S","<:^S","<=^S","<:oS","<=oS",
			"<=}","<={","<:}","<:{","<:@","<:?","<=?","<:-?","<=-?","<:^?","<=^?","<:o?","<=o?",
			"<:$","<=$","<:-$","<=-$","<:^$","<=^$","<:o$","<=o$")
		iconstate = "sad/weird"
	sad_uncertain
		smileys = list("<:/","<:\\","<=/","<=\\","<:o\\","<:o/","<=^/","<=^\\","<:^/","<:^\\",
			"<=-/","<=-\\","<:-/","<:-\\")
		iconstate = "sad/uncertain"
	uncertain_skeptical2
		smileys = list("/:/","/:\\","/=/","/=\\","/:o\\","/:o/","/=^/","/=^\\","/:^/","/:^\\",
			"/=-/","/=-\\","/:-/","/:-\\","\\:/","\\:\\","\\=/","\\=\\","\\:o\\","\\:o/",
			"\\=^/","\\=^\\","\\:^/","\\:^\\","\\=-/","\\=-\\","\\:-/","\\:-\\")
		iconstate = "uncertain/skeptical2"
	skeptical2
		smileys = list("/=|","/:|","/:-|","/=-|","/=^|","/:^|","/=o|","/:o|","/=l",
			"/:l","/:-l","/=-l","/=^l","/:^l","/=I","/:I","/:-I","/=-I","/=^I","/:^I",
			"/=oI","/:oI","\\=|","\\:|","\\:-|","\\=-|","\\=^|","\\:^|","\\=o|","\\:o|",
			"\\=l","\\:l","\\:-l","\\=-l","\\=^l","\\:^l","\\=I","\\:I","\\:-I","\\=-I",
			"\\=^I","\\:^I","\\=oI","\\:oI")
		iconstate = "skeptical2"
	sad_skeptical2
		smileys = list("/=(","/:(","/:-(","/=-(","/=^(","/:^(","/=\[","/:\[","/:-\[",
			"/=-\[","/=^\[","/:^\[","/:<","/:-<","/=-<","/=^<","/:^<","/:o\[","/:o(",
			"/=o\[","/=o(","\\=(","\\:(","\\:-(","\\=-(","\\=^(","\\:^(","\\=\[","\\:\[",
			"\\:-\[","\\=-\[","\\=^\[","\\:^\[","\\:<","\\:-<","\\=-<","\\=^<","\\:^<",
			"\\:o\[","\\:o(","\\=o\[","\\=o(")
		iconstate = "sad/skeptical2"
	happy_skeptical2
		smileys = list("/=)","/:)","/:-)","/=-)","/=^)","/:^)","/=)","/:]","/:-]",
			"/=-]","/=^]","/:^]","/:>","/:->","/=->","/=^>","/:^>","/:o]","/:o)",
			"/=o]","/=o)","\\=)","\\:)","\\:-)","\\=-)","\\=^)","\\:^)","\\=]","\\:]",
			"\\:-]","\\=-]","\\=^]","\\:^]","\\:>","\\:->","\\=->","\\=^>","\\:^>",
			"\\:o]","\\:o)","\\=o]","\\=o)")
		iconstate = "happy/skeptical2"
	wink_grin
		smileys = list(";D",";-D",";^D")
		iconstate = "wink/grin"
	tongue2
		smileys = list("=p",":p",":-p","=-p","=^p",":^p","=þ",":þ",":-þ","=-þ","=^þ",":^þ",
			"=oþ",":oþ","=op",":op")
		iconstate = "tongue2"
	tongue
		smileys = list("=P",":P",":-P","=-P","=^P",":^P","=oP",":oP")
		iconstate = "tongue"
	grin
		smileys = list("=D",":D",":-D","=-D","=^D",":^D")
		iconstate = "grin"
	wink
		smileys = list(";)",";-)",";^)",";\]",";-\]",";^\]",";>",";->",";^>",
			"^_-","-_^","^.-","-.^","O_-","-_O","O.-","-.O","o_-","-_o","o.-","-.o",
			"0_-","-_0","0.-","-.0")
		iconstate = "wink"
	sad_wink_a
		smileys = list(";(",";-(",";^(",";\[",";-\[",";^\[",";<",";-<",";^<")
		iconstate = "sad wink_a"
	wink_tongue2
		smileys = list(";p",";-p",";^p",";þ",";-þ",";^þ",";oþ",";op")
		iconstate = "wink/tongue2"
	wink_tongue
		smileys = list(";P",";-P",";^P",";oP")
		iconstate = "wink/tongue"
	smile
		smileys = list("=)",":)",":-)","=-)","=^)",":^)","=\]",":\]",":-\]","=-\]",
			"=^\]",":^\]","=\]",":>",":->","=->","=^>",":^>","=o>",":o>","=o)","=o\]",
			":o)",":o\]")
		iconstate = "smile"
	neutral
		smileys = list("=|",":|",":-|","=-|","=^|",":^|","o_o","o.o","=o|",":o|",
			"=l",":l",":-l","=-l","=^l",":^l","=I",":I",":-I","=-I","=^I",":^I","=oI",":oI")
		iconstate = "neutral"
	sad_a
		smileys = list("=(",":(",":-(","=-(","=^(",":^(","=\[",":\[",":-\[","=-\[",
			"=^\[",":^\[",":<",":-<","=-<","=^<",":^<",":o<",":o(",":o\[","=o<","=o(","=o\[")
		iconstate = "sad_a"
	crying_a
		smileys = list("=.(",":.(",":.-(","=.-(","=.^(",":.^(","=.\[",":.\[",":.-\[",
			"=.-\[","=.^\[",":.^\[",":.<",":.-<","=.-<","=.^<",":.^<",":.o\[",":.o(",
			"=.o\[","=.o(","=,(",":,(",":,-(","=,-(","=,^(",":,^(","=,\[",":,\[",":,-\[",
			"=,-\[","=,^\[",":,^\[",":,<",":,-<","=,-<","=,^<",":,^<",":,o\[",":,o(",
			"=,o\[","=,o(","=\'(",":\'(",":\'-(","=\'-(","=\'^(",":\'^(","=\'\[",":\'\[",":\'-\[",
			"=\'-\[","=\'^\[",":\'^\[",":\'<",":\'-<","=\'-<","=\'^<",":\'^<",":\'o\[",":\'o(",
			"=\'o\[","=\'o(","=*(",":*(",":*-(","=*-(","=*^(",":*^(","=*\[",":*\[",":*-\[",
			"=*-\[","=*^\[",":*^\[",":*<",":*-<","=*-<","=*^<",":*^<",":*o\[",":*o(",
			"=*o\[","=*o(")
		iconstate = "crying_a"
	thoughtful_wink
		smileys = list(";|",";-|",";^|",";o|",";l",";-l",";^l",";ol",";I",";-I",";^I",";oI")
		iconstate = "thoughtful wink"
	weird
		smileys = list(":S","=S","=oS",":oS",":-S","=-S",":^S","=^S",":oS","=oS","=}",
			"={",":}",":{",":@","@.@",":?","=?",":-?","=-?",":^?","=^?",":o?","=o?",
			":$","=$",":-$","=-$",":^$","=^$",":o$","=o$")
		iconstate = "weird"
	surprised_a
		smileys = list("=o",":o",":-o","=-o","=^o",":^o","=O",":O",":-O","=-O","=^O",
			":^O","=oo",":oo","=oO",":oO",":0",":-0","=0","=-0",
			":^0","=^0",":o0","=o0")
		iconstate = "surprised_a"
	anime_smile
		smileys = list("^_^")
		iconstate = "anime smile"
	anime_O
		smileys = list("^.^")
		iconstate = "anime O"
	anime_sleepy
		smileys = list("-_-","-.-")
		iconstate = "anime sleepy"
	shifty
		smileys = list("<.<","<_<")
		iconstate = "shifty"
	shifty2
		smileys = list(">.>",">_>")
		iconstate = "shifty2"
	uncertain
		smileys = list(":/",":\\","=/","=\\",":o\\",":o/","=^/","=^\\",":^/",":^\\",
			"=-/","=-\\",":-/",":-\\")
		iconstate = "uncertain"
	odd_a
		smileys = list("o.0","o_0","o.O","o_O")
		iconstate = "odd_a"
	odd_b
		smileys = list("0.o","0_o","O.o","O_o")
		iconstate = "odd_b"
	odd_amazed
		smileys = list("0_0","0.0","O.O","O_O")
		iconstate = "odd/amazed"


proc/s_smileys(text as text,var/test,icon/smileys)
	var/found_smileys = 0
	var/smiley/smiley
	for(smiley in s_smileys)
		var/B
		for(B in smiley.smileys)
			if(!findtext(text,B)) continue

			found_smileys++

			var/image/O = new
			O.icon = smileys
			O.icon_state = smiley.iconstate
			text = replaceWord(text, B, "<IMG CLASS=\"icon\" SRC=\"\ref[O.icon]\" \
				ICONSTATE=\"[smiley.iconstate]\">")
			del O
	if(test)
		return found_smileys
	else
		return(text)