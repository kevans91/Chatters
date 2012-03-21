///////////////////
// TEXT HANDLING //
///////////////////
/*
 This text handling library is a Deadron core library,
 providing some helpful text functions not found in BYOND.

 To include this library, click the library checkbox in the
 Lib folder of the file tree, or add this line in your code:

#include <deadron/texthandling>

 If you have suggestions or questions, please email
 ron@deadron.com.

 Copyright (c) 1999, 2000, 2001, 2002, 2003 Ronald J. Hayden. All rights reserved.

 09/12/03: Integrated Crispy's changes so dd_text2list() supports non-text items in list.
 02/10/02: Added dd_centertext() and dd_limittext().

dd_file2list(file_path, separator = "\n")
	Splits the text from the specified file into a list.
	file_path is the path to the file.
	separator is an optional delimiter between items in the file;
	it defaults to "\n", which makes each line of the file an item in the list.

	Example:

	// Read in the list of possible NPC names.
	var/list/names = dd_file2list("NPCs.txt")

dd_replacetext(text, search_string, replacement_string)
	Returns a new string replacing all occurrences of search_string in text
	with replacement_string. This is not case-sensitive.

	Example:

	verb/say(msg as text)
		// Don't let the player fake people out using line breaks when they say things.
		// Replace any instances of <BR> or /n with a space.
		var/search_string = "<BR>"
		var/replacement = " "
		var/sanitized_text = dd_replacetext(msg, search_string, replacement)

		search_string = "/n"
		sanitized_text = dd_replacetext(sanitized_text, search_string, replacement)

		view(src) << sanitized_text
		return

dd_replaceText(text, search_string, replacement_string)
	The case-sensitive version of dd_replacetext().

dd_hasprefix(text, prefix)
	Returns 1 if the text has the specified prefix, 0 otherwise.  This version is not case sensitive.

	Example:

	// Does the player's name have GM as the prefix?
	if (dd_hasprefix(name, "GM"))
		// Give them GM abilities.

dd_hasPrefix(text, prefix)
	The case-sensitive version of dd_hasprefix.

dd_hassuffix(text, suffix)
	Returns 1 if the text has the specified prefix, 0 otherwise.
	This version is not case sensitive.

dd_hasSuffix(text, suffix)
	Returns 1 if the text has the specified prefix, 0 otherwise.
	This version is case sensitive.

dd_text2list(text, separator)
	Split the text into a list, where separator is the delimiter between items.
	Returns the list. This is not case-sensitive.

	If the myText string is "a = b = c", and you call dd_text2list(myText, " = "), you get a list back with these items:
		a
		b
		c

	Example:

	// Get a list containing the names in this string.
	var/mytext = "George; Bernard; Shaw"
	var/separator = "; "
	var/list/names = dd_text2list(mytext, separator)

dd_text2List(text, separator)
	The case-sensitive version of dd_text2list().

dd_list2text(list/the_list, separator)
	Create a string by combining each element of the list,
	inserting the separator between each item.

	Example:

	// Turn this list of names into one string separated by semi-colons.
	var/list/names = list("George", "Bernard", "Shaw")
	var/separator = "; "
	var/mytext = dd_list2text(names, separator)

dd_centertext(message, length)
	Returns a new text string, centered based on the length.

	If the string is not as long as the length, spaces are added
	on both sides of the message.

	If the string is longer than the specified length, the message
	is truncated to fit to the length.

	This function is useful when laying out text on the map, where you
	might want to center a title, for example.

dd_limittext(message, length)
	If the message is longer than length, truncates the message to fit
	length. This is useful for text on the map, where you might want
	to display a player name, for example, but have to make sure it's
	not too long to fit.
*/




proc
	///////////////////
	// Reading files //
	///////////////////
	dd_file2list(file_path, separator = "\n")
		var/file
		if (isfile(file_path))
			file = file_path
		else
			file = file(file_path)
		return dd_text2list(file2text(file), separator)


    ////////////////////
    // Replacing text //
    ////////////////////
	dd_replacetext(text, search_string, replacement_string)
		// A nice way to do this is to split the text into an array based on the search_string,
		// then put it back together into text using replacement_string as the new separator.
		var/list/textList = dd_text2list(text, search_string)
		return dd_list2text(textList, replacement_string)


	dd_replaceText(text, search_string, replacement_string)
		var/list/textList = dd_text2List(text, search_string)
		return dd_list2text(textList, replacement_string)


    /////////////////////
	// Prefix checking //
	/////////////////////
	dd_hasprefix(text, prefix)
		var/start = 1
		var/end = lentext(prefix) + 1
		return findtext(text, prefix, start, end)

	dd_hasPrefix(text, prefix)
		var/start = 1
		var/end = lentext(prefix) + 1
		return findtextEx(text, prefix, start, end)


    /////////////////////
	// Suffix checking //
	/////////////////////
	dd_hassuffix(text, suffix)
		var/start = length(text) - length(suffix)
		if (start) return findtext(text, suffix, start)

	dd_hasSuffix(text, suffix)
		var/start = length(text) - length(suffix)
		if (start) return findtextEx(text, suffix, start)

	/////////////////////////////
	// Turning text into lists //
	/////////////////////////////
	dd_text2list(text, separator)
		var/textlength      = lentext(text)
		var/separatorlength = lentext(separator)
		var/list/textList   = new /list()
		var/searchPosition  = 1
		var/findPosition    = 1
		var/buggyText
		while (1)															// Loop forever.
			findPosition = findtext(text, separator, searchPosition, 0)
			buggyText = copytext(text, searchPosition, findPosition)		// Everything from searchPosition to findPosition goes into a list element.
			textList += "[buggyText]"										// Working around weird problem where "text" != "text" after this copytext().

			searchPosition = findPosition + separatorlength					// Skip over separator.
			if (findPosition == 0)											// Didn't find anything at end of string so stop here.
				return textList
			else
				if (searchPosition > textlength)							// Found separator at very end of string.
					textList += ""											// So add empty element.
					return textList

	dd_text2List(text, separator)
		var/textlength      = lentext(text)
		var/separatorlength = lentext(separator)
		var/list/textList   = new /list()
		var/searchPosition  = 1
		var/findPosition    = 1
		var/buggyText
		while (1)															// Loop forever.
			findPosition = findtextEx(text, separator, searchPosition, 0)
			buggyText = copytext(text, searchPosition, findPosition)		// Everything from searchPosition to findPosition goes into a list element.
			textList += "[buggyText]"										// Working around weird problem where "text" != "text" after this copytext().

			searchPosition = findPosition + separatorlength					// Skip over separator.
			if (findPosition == 0)											// Didn't find anything at end of string so stop here.
				return textList
			else
				if (searchPosition > textlength)							// Found separator at very end of string.
					textList += ""											// So add empty element.
					return textList

	dd_list2text(list/the_list, separator)
		var/total = the_list.len
		if (total == 0)														// Nothing to work with.
			return

		var/newText = "[the_list[1]]"										// Treats any object/number as text also.
		var/count
		for (count = 2, count <= total, count++)
			if (separator) newText += separator
			newText += "[the_list[count]]"
		return newText

	dd_centertext(message, length)
		var/new_message = message
		var/size = length(message)
		if (size == length)
			return new_message
		if (size > length)
			return copytext(new_message, 1, length + 1)

		// Need to pad text to center it.
		var/delta = length - size
		if (delta == 1)
			// Add one space after it.
			return new_message + " "

		// Is this an odd number? If so, add extra space to front.
		if (delta % 2)
			new_message = " " + new_message
			delta--

		// Divide delta in 2, add those spaces to both ends.
		delta = delta / 2
		var/spaces = ""
		for (var/count = 1, count <= delta, count++)
			spaces += " "
		return spaces + new_message + spaces

	dd_limittext(message, length)
		// Truncates text to limit if necessary.
		var/size = length(message)
		if (size <= length)
			return message
		else
			return copytext(message, 1, length + 1)

/***
#define MT_BOL	0x80 | '^'	// beginning of line

	dd_grep(regex, file_or_text)
		var/text

		if (isfile(file_or_text))
			text = file2text(file_or_text)
		else
			text = file_or_text

		return text
***/

/*
 * Using Deadron's Test library.
 */
obj/test/texthandling/verb/dd_list2text_test()
	var/list/mylist = new()
	mylist += "one"

	var/obj/basic = new()
	basic.name = "two"
	mylist += basic

	var/text = dd_list2text(mylist, ",")
	if (text != "one,The two")
		die("dd_list2text() returned incorrect text: [text]")

	mylist -= basic
	del(basic)
	del(mylist)

