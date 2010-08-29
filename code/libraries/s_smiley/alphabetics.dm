//Credit to: Spuzzum
//Contributed by: Spuzzum


//These are a few functions that allow you to determine
// whether or not a character is a letter, a vowel, or
// anything else.


#define isconsonant(X) alphabet_consonants.Find(X) ? 1 : 0
#define isvowel(X) alphabet_vowels.Find(X) ? 1 : 0
#define isalphabetic(X) complete_alphabet.Find(X) ? 1 : 0
#define isuppercase(X) uppercase_alphabet.Find(X) ? 1 : 0
#define islowercase(X) lowercase_alphabet.Find(X) ? 1 : 0


var/list/lowercase_alphabet = list("a","b","c","d","e","f",
	"g","h","i","j","k","l","m","n","o","p","q","r","s","t",
	"u","v","w","x","y","z","ç","ñ","à","á","â","ã","ä","å",
	"æ","è","é","ê","ë","ì","í","î","ï","ò","ó","ô","õ","ö",
	"ø","ù","ú","û","ü","ý")
var/list/uppercase_alphabet = list("A","B","C","D","E","F",
	"G","H","I","J","K","L","M","N","O","P","Q","R","S","T",
	"U","V","W","X","Y","Z","Ç","Ñ","À","Á","Â","Ã","Ä","Å",
	"Æ","È","É","Ê","Ë","Ì","Í","Î","Ï","Ò","Ó","Ô","Õ","Ö",
	"Ø","Ù","Ú","Û","Ü","Ý")

var/list/alphabet_vowels = list(\
	"a","e","i","o","u","y","à","á","â","ã","ä","å","æ","è",
	"é","ê","ë","ì","í","î","ï","ò","ó","ô","õ","ö","ø","ù",
	"ú","û","ü","ý",
	"A","E","I","O","U","Y","À","Á","Â","Ã","Ä","Å","Æ","È",
	"É","Ê","Ë","Ì","Í","Î","Ï","Ò","Ó","Ô","Õ","Ö","Ø","Ù",
	"Ú","Û","Ü","Ý")

var/list/alphabet_consonants = list(\
	"b","c","d","f","g","h","j","k","l","m","n","p","q","r",
	"s","t","v","w","x","z","ç","ñ",
	"B","C","D","F","G","H","J","K","L","M","N","P","Q","R",
	"S","T","V","W","X","Z","Ç","Ñ")

var/list/complete_alphabet = lowercase_alphabet + uppercase_alphabet



proc/lowercase(string)
	//Returns a lower case string.  Replaces BYOND-provided
	// lowertext(), as that doesn't support accented characters.
	//Note that lowertext() is far more efficient.  Only use this
	// if you need to change the case of strings that will most
	// likely contain accented characters.

	var/new_string = ""
	var/string_len = lentext(string)

	for(var/i = 1, i <= string_len, i++)
		var/char = copytext(string,i,i+1)
		var/index = uppercase_alphabet.Find(char)
		if(index) new_string += lowercase_alphabet[index]
		else new_string += char

	return(new_string)


proc/uppercase(string)
	//As lowercase, but for upper case.

	var/new_string = ""
	var/string_len = lentext(string)

	for(var/i = 1, i <= string_len, i++)
		var/char = copytext(string,i,i+1)
		var/index = lowercase_alphabet.Find(char)
		if(index) new_string += uppercase_alphabet[index]
		else new_string += char

	return(new_string)