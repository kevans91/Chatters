//Credit to: Spuzzum
//Contributed by: Spuzzum
//Dependency of: alphabetics snippet (Spuzzum)

//This snippet of code replaces *words* in a sentence.
// In this fashion, it avoids accidentally replacing letters
// that belong to other words.  For example, if you had this
// string:

// I am very intelligent.

// ...and you decided to replace the word I, you'd get:

// x am very xntellxgent

// ...if you used the replacetext snippet.  With this snippet,
// you'd get:

// x am very intelligent

// which is hopefully what the doctor ordered.

#include "alphabetics.dm"

proc/replaceword(string, search, replace)
	if(!findtext(string, search)) return string
	var/tmp/string_len = lentext(string)
	var/tmp/search_len = lentext(search)
	var/tmp/replace_len = lentext(replace)

	var/tmp/last_char = 0 //0 -- non-alphabetic, 1 -- alphabetic or numeral
	//anything in the ignore list is assumed to be a part of a word
	var/list/ignores = list("'","1","2","3","4","5","6","7","8","9",",",".")

	for(var/pos = 1, pos <= string_len-search_len+1, pos++)
		var/char = copytext(string, pos, pos+1) //determine if this is a break between words
		if(isalphabetic(char) || ignores.Find(char) || findtext(search, char))
			if(!last_char)

				var/following_char = " " //defaults to a space in case it's the end of the string
				if(pos+search_len <= string_len) //avoid going out of bounds
					following_char = copytext(string, pos+search_len, pos+search_len+1)

				//if the search string is followed by a non-alpha, we have a complete word
				if(!isalphabetic(following_char))
					//now, if the word matches, replace it appropriately!
					if(cmptext(copytext(string, pos, pos+search_len), search))
						string = copytext(string, 1, pos) + replace + copytext(string, pos+search_len)
						string_len += replace_len - search_len

				last_char = 1 //toggle the state of the last character
		else if(last_char) last_char = 0
	return(string)

proc/replaceWord(String, Search, Replace)
	if(!findtextEx(String, Search)) return String
	var/tmp/String_len = lentext(String)
	var/tmp/Search_len = lentext(Search)
	var/tmp/Replace_len = lentext(Replace)

	var/tmp/last_Char = 0 //0 -- non-alphabetic, 1 -- alphabetic or numeral
	//anything in the ignore list is assumed to be a part of a word
	var/list/Ignores = list("'","1","2","3","4","5","6","7","8","9",",",".")

	for(var/Pos = 1, Pos <= String_len-Search_len+1, Pos++)
		var/Char = copytext(String, Pos, Pos+1) //determine if this is a break between words
		if(isalphabetic(Char) || Ignores.Find(Char) || findtextEx(Search, Char))
			if(!last_Char)

				var/following_Char = " " //defaults to a space in case it's the end of the string
				if(Pos+Search_len <= String_len) //avoid going out of bounds
					following_Char = copytext(String, Pos+Search_len, Pos+Search_len+1)

				//if the search string is followed by a non-alpha, we have a complete word
				if(!isalphabetic(following_Char))
					//now, if the word matches, replace it appropriately!
					if(cmptextEx(copytext(String, Pos, Pos+Search_len), Search))
						String = copytext(String, 1, Pos) + Replace + copytext(String, Pos+Search_len)
						String_len += Replace_len - Search_len

				last_Char = 1 //toggle the state of the last character
		else if(last_Char) last_Char = 0
	return(String)