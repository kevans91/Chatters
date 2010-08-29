//Credit to: Spuzzum
//Contributed by: Spuzzum

//REPLACE_TEXT PROC
// This is a text-replacement function.  There is one
// included in the Deadron library, but this one avoids
// using lists and relies upon strings directly, making
// it more rapid (presumably).

//Updated version: will never be thrown into an infinite loop!


proc/replacetext(string, search, replace)
	if(!findtext(string, search)) return string
	var/string_len = lentext(string)
	var/search_len = lentext(search)
	var/replace_len = lentext(replace)

	for(var/pos = 1, pos <= string_len, pos++)
		if(cmptext(copytext(string, pos, pos+search_len), search))
			string = copytext(string, 1, pos) + replace + copytext(string, pos+search_len)
			string_len += replace_len - search_len
	return(string)

proc/replaceText(String, Search, Replace)
	if(!findText(String, Search)) return String
	var/String_len = lentext(String)
	var/Search_len = lentext(Search)
	var/Replace_len = lentext(Replace)

	for(var/Pos = 1, Pos <= String_len, Pos++)
		if(cmpText(copytext(String, Pos, Pos+Search_len), Search))
			String = copytext(String, 1, Pos) + Replace + copytext(String, Pos+Search_len)
			String_len += Replace_len - Search_len