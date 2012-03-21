#include "XML.dm"
XML/Parser
	var
		text
		offset = 1
		scan_offset		// Used by scanning functions so they can look at text without changing real offset.
		list/errors

	New(the_text)
		text = the_text
		return ..()

	proc/RegisterError(message)
		// TODO: report line/char on line
		if (!errors) errors = list()
		errors += message
//		CRASH(message)

	proc/Error()
		var/message = ""
		if (errors)
			for (var/error in errors)
				message += "[error]\n"
		return message

	proc/Parse_element()
		scan_offset = offset
		var/XML/Element/element = Scan_element()
		if (element) offset = scan_offset
		return element

	proc/Scan_element()
		// [39] element ::= EmptyElemTag | STag content ETag
		// [WFC: Element Type Match]
		// [40] STag ::= '<' Name (S Attribute)* S? '>'
		// [WFC: Unique Att Spec]
		// [44] EmptyElemTag ::= '<' Name (S Attribute)* S? '/>'
		// [WFC: Unique Att Spec]
		// [42] ETag ::= '</' Name S? '>'
		var/orig_scan_offset = scan_offset
		if (!ScanText("<")) return

		var/name = Scan_Name()
		if (!name)
			scan_offset = orig_scan_offset
			return

		var/list/attributes = ScanAttributes()

		Scan_S()

		if (ScanText("/>")) goto finish	// Empty element
		if (!ScanText(">"))
			RegisterError("Unclosed element: [name].")
			return

		var/list/children = Scan_content()

		if (!ScanText("</[name]"))
			RegisterError("Unclosed element: [name].")
			return

		Scan_S()

		if (!ScanText(">"))
			RegisterError("[name] closing element missing closing \">\".")
			return

		finish
		var/XML/Element/element = new()
		element.setTag(name)
		element.setAttributes(attributes)
		element.setChildren(children)
		return element

	proc/Parse_content()
		scan_offset = offset
		var/list/children = Scan_content()
		if (children) offset = scan_offset
		return children

	proc/Scan_content()
		// [43] content ::= CharData? ((element | Reference | CDSect | PI | Comment) CharData?)*
		var/list/items = new()

		// CharData
		var/XML/Element/Special/PCDATA/pcdata = Scan_CharData()
		if (pcdata) items += pcdata

		while(1)
			// element
			var/XML/Element/element = Scan_element()
			if (element)
				items += element
				continue

			// Reference
			var/reference = Scan_Reference()
			if (reference)
				// For now treating Entity as PCDATA; may want Entity element when we get more sophisticated.
				pcdata = new()
				pcdata.setXML(reference)
				items += pcdata
				continue

			// CDSect
			var/XML/Element/Special/CDATA/cdata = Scan_CDSect()
			if (cdata)
				items += cdata
				continue

			// TODO/COMPLIANCE: PI

			// Comment
			var/comment_text = Scan_Comment()
			if (comment_text)
				var/XML/Element/Special/Comment/comment = new(comment_text)
				items += comment
				continue

			// CharData
			pcdata = Scan_CharData()
			if (pcdata)
				items += pcdata
				continue

			break

		if (items.len) return items

	proc/Scan_CDSect()
		// [18] CDSect ::= CDStart CData CDEnd
		// [19] CDStart ::= '<![CDATA['
		// [20] CData ::= (Char* - (Char* ']]>' Char*))
		// [21] CDEnd ::= ']]>'
		// COMPLIANCE: Not sure how illegal ]]> in 20 is supposed to be checked for.
		var/string = ""
		var/char

		var/open = ScanText("<!\[CDATA\[")
		if (!open) return

		while (1)
			char = ScanText()
			if (!char)
				RegisterError("Unexpectedly reached end of text.")
				return

			// Have we reached the closing?
			if (char == "]")
				if (ScanText("]>"))
					break

			string += char
		return new /XML/Element/Special/CDATA(string)

	proc/Scan_CharData()
		// [14] CharData ::= [^<&]* - ([^<&]* ']]>' [^<&]*)
		// text that doesn't contain ']]>'
		var/scan_offset_start = scan_offset
		var/string = ""
		var/char

		while (1)
			char = ScanText()
			if (char)
				if (char == "<" || char == "&")
					// Forget this character.
					scan_offset--
					break

				string += char
			else
				break

		if (!string) return

		if (findtextEx(string, "]]>"))
			// Forget this whole sequence.
			scan_offset = scan_offset_start
			return

		return new /XML/Element/Special/PCDATA(string)

	proc/ScanAttributes()
		var/list/attributes = new()

		while(1)
			var/space = Scan_S()
			if (!space) break

			var/XML/Attribute/attribute = Scan_Attribute()
			if (!attribute)
				// Move cursor back to before the space characters.
				scan_offset -= length(space)
				break

			if (attributes[attribute.name])
				RegisterError("Duplicate attribute: [attribute.name]")
				return

			attributes[attribute.name] = attribute.value
		return attributes

	proc/Parse_Attribute(attribute)
		scan_offset = offset
		var/value = Scan_Attribute(attribute)
		if (!value) return

		offset = scan_offset
		return value

	proc/Scan_Attribute(attribute)
		// [41] Attribute ::= Name Eq AttValue
		// 	[WFC: No External Entity References]
		//  [WFC: No < in Attribute Values]
		//
		// Scans for the specified attribute and returns the value.
		// If no attribute specified, sees if any attribute is defined here and returns an attribute object.
		var/start_offset = scan_offset
		var/name = Scan_Name()
		if (attribute && name != attribute) goto cleanup

		var/equals = Scan_Eq()
		if (!equals) goto cleanup

		var/value = Scan_AttValue()
		if (value != -1)
			// Does this have illegal < in it?
			if (findtextEx(value, "<"))
				RegisterError("Attribute value cannot have the \"<\" character; use &lt; instead.")
				return

			if (!attribute)
				// Return an attribute object so the caller knows the name and the value.
				return new /XML/Attribute(name, value)
			return value

		cleanup
		scan_offset = start_offset
		return

	proc/Parse_Name()
		scan_offset = offset
		var/name = Scan_Name()
		if (!name) return

		offset = scan_offset
		return name

	proc/Scan_Name()
		// [5] Name ::= (Letter | '_' | ':') (NameChar)*
		// [4] NameChar ::= Letter | Digit | '.' | '-' | '_' | ':' | CombiningChar | Extender
		var/start_offset = scan_offset
		var/name = Scan_Letter()
		if (!name)
			var/list/chars = list("_", ":")
			name = ScanText(chars)
		if (!name) goto cleanup

		var/char
		while(1)
			char = Scan_Letter()
			if (!char) char = Scan_Digit()
			if (!char)
				var/list/chars = list(".", "-", "_", ":")
				char = ScanText(chars)
			if (char)
				name += char
			else
				return name

		cleanup
		scan_offset = start_offset
		return

	proc/Parse_SystemLiteral()
		scan_offset = offset
		var/system = Scan_SystemLiteral()
		if (!system) return

		offset = scan_offset
		return system

	proc/Scan_SystemLiteral()
		// [11] SystemLiteral ::= ('"' [^"]* '"') | ("'" [^']* "'")
		var/delimiter = ScanText(list("\"", "'"))
		if (!delimiter) return
		var/system = ScanTextExcluding(delimiter)
		ScanText(delimiter)
		return "[delimiter][system][delimiter]"

	proc/Parse_PubidLiteral()
		scan_offset = offset
		var/system = Scan_PubidLiteral()
		if (!system) return

		offset = scan_offset
		return system

	proc/Scan_PubidLiteral()
		// [12] PubidLiteral ::= '"' PubidChar* '"' | "'" (PubidChar - "'")* "'"
		// [13] PubidChar ::= #x20 | #xD | #xA | [a-zA-Z0-9] | [-'()+,./:=?;!*#@$_%]
		// COMPLIANCE: Not checking for the specific characters here.
		var/delimiter = ScanText(list("\"", "'"))
		if (!delimiter) return
		var/pubid = ScanTextExcluding(delimiter)
		ScanText(delimiter)
		return "[delimiter][pubid][delimiter]"

	proc/Scan_AttValue()
		// [10] AttValue ::= '"' ([^<&"] | Reference)* '"' |  "'" ([^<&'] | Reference)* "'"
		// COMPLIANCE: Need to follow the attribute normalization algorithm
		// Since it's possible to have valid zero value chars (att=""), return -1 if no attribute found.
		var/start_offset = scan_offset
		var/list/delimiters = list("\"", "'")
		var/delimiter = ScanText(delimiters)
		if (!delimiter) goto cleanup

		var/value = ""
		var/list/exclusions = list("<", "&", delimiter)
		while(1)
			var/string = ScanTextExcluding(exclusions)
			if (string) value += string

			var/excluded = LookText()
			switch(excluded)
				if ("&")
					var/reference = Scan_Reference()
					if (reference)
						value += reference
					else
						RegisterError("AttValue not well-formed; entity started but not completed.")
						goto cleanup
				if ("\"", "'")
					// We're done. Move offset past the delimiter.
					scan_offset++
					return value
				else
					RegisterError("AttValue not properly closed.")
					goto cleanup

		cleanup
		scan_offset = start_offset
		return -1

	proc/Scan_Reference()
		// [67]   Reference ::= EntityRef | CharRef
		var/reference = Scan_EntityRef()
		if (!reference) Scan_CharRef()
		return reference

	proc/Scan_EntityRef()
		// [68] EntityRef ::= '&' Name ';'
		// [WFC: Entity Declared] [WFC: Parsed Entity] [WFC: No Recursion]
		var/start_offset = scan_offset
		var/ampersand = ScanText("&")
		if (!ampersand) goto cleanup

		var/name = Scan_Name()
		if (!name) goto cleanup

		var/semicolon = ScanText(";")
		if (semicolon) return "&[name];"

		cleanup
		scan_offset = start_offset
		return

	proc/Scan_CharRef()
		// [66]   CharRef ::= '&#' [0-9]+ ';' | '&#x' [0-9a-fA-F]+ ';' [WFC: Legal Character]
		var/start_offset = scan_offset
		var/reference = ""
		var/opening = ScanText("&#x")
		if (opening)
			// This form allows digits or letters.
			var/char
			while(1)
				char = ScanAlphaNumeric()
				if (char)
					reference += char
				else
					break
		else
			// Check for other opening.
			opening = ScanText("&#")
			if (!opening) goto cleanup

			var/digit
			while(1)
				digit = Scan_Digit()
				if (digit)
					reference += digit
				else
					break

		if (!reference)
			RegisterError("CharRef has no content.")
			goto cleanup

		var/closing = ScanText(";")
		if (!closing)
			RegisterError("CharRef not properly closed.")
			goto cleanup

		return "[opening][reference][closing]"

		cleanup
		scan_offset = start_offset
		return

	proc/Parse_Misc()
		scan_offset = offset

		var/XML/Element/element = Scan_Misc()
		if (!element) return

		offset = scan_offset
		return element

	proc/Scan_Misc()
		// [27] Misc ::= Comment | PI | S
		var/string = Scan_Comment()
		if (string) return new /XML/Element/Special/Comment(string)

		string = Scan_PI()
		if (string) return new /XML/Element/Special/PI(string)

		string = Scan_S()
		if (string) return new /XML/Element/Special/PCDATA(string)

	proc/Scan_Comment()
		// [15] Comment ::= '<!--' ((Char - '-') | ('-' (Char - '-')))* '-->'
		var/string = ScanText("<!--")
		if (!string) return

		while(1)
			string = ScanTextExcluding("-")

			// Are we at the end?
			if (ScanText("-->")) return string

			// Is this an illegal double-hyphen?
			if (ScanText("--"))
				RegisterError("Comment cannot have double-hyphen (--) as part of it's content.")
				return

			// It's just a single hyphen.
			string += ScanText("-")

	proc/Scan_PI()
		// [16] PI ::= '<?' PITarget (S (Char* - (Char* '?>' Char*)))? '?>'
		// [17] PITarget ::= Name - (('X' | 'x') ('M' | 'm') ('L' | 'l'))
		// TODO/COMPLIANCE: support this

	proc/ScanAlphaNumeric()
		var/ascii = text2ascii(text, scan_offset)

		// Check lowercase and uppercase letters.
		if ((ascii >= 97 && ascii <= 122) || \
		    (ascii >= 65 && ascii <= 90)  || \
		    (ascii >= 48 && ascii <= 57))
			scan_offset++
			return ascii2text(ascii)

	proc/Scan_Letter()
		// [84] Letter ::= BaseChar | Ideographic
		// COMPLIANCE: Not checking full set of possible characters here...just standard letters.
		var/ascii = text2ascii(text, scan_offset)

		// Check lowercase and uppercase letters.
		if ((ascii >= 97 && ascii <= 122) || \
		    (ascii >= 65 && ascii <= 90))
			scan_offset++
			return ascii2text(ascii)

	proc/Scan_Digit()
		// [88] Digit
		// COMPLIANCE: Not checking full set of possible characters...just standard digits.
		var/ascii = text2ascii(text, scan_offset)

		if (ascii >= 48 && ascii <= 57)
			scan_offset++
			return ascii2text(ascii)

	proc/ParseText(text_or_list)
		// Returns text that was found.
		scan_offset = offset
		var/string = ScanText(text_or_list)
		if (!string) return

		offset = scan_offset
		return string

	proc/ScanText(text_or_list)
		// Scans for the specified text items.
		// If nothing specified, returns next character.
		if (!text_or_list)
			var/char = copytext(text, scan_offset, scan_offset + 1)
			if (char) scan_offset++
			return char

		var/list/items = list()
		items += text_or_list

		for (var/item in items)
			var/end = scan_offset + lentext(item)
			var/position = findtextEx(text, item, scan_offset, end)
			if (position)
				scan_offset = end
				return item

	proc/ParseTextExcluding(text_or_list)
		// Returns text that was found.
		scan_offset = offset
		var/string = ScanTextExcluding(text_or_list)
		if (!string) return

		offset = scan_offset
		return string

	proc/ScanTextExcluding(text_or_list)
		// Scans text until it reaches one of the specified items.
		var/list/items = list()
		items += text_or_list

		var/string = ""
		while(1)
			var/char = LookText()
			if (!char || char in items)
				return string

			string += char
			scan_offset++

	proc/LookText(text_or_list)
		// Looks ahead for the specified text items without changing any offsets.
		// If nothing specified, returns next character.
		if (!text_or_list)
			return copytext(text, scan_offset, scan_offset + 1)

		var/list/items = list()
		items += text_or_list

		for (var/item in items)
			var/end = scan_offset + lentext(item)
			var/position = findtextEx(text, item, scan_offset, end)
			if (position)
				return item

	proc/ScanAscii(number_or_list)
		// Scans for whether the next character is one of the specified ascii characters.
		var/list/items = list()
		items += number_or_list

		for (var/item in items)
			if (text2ascii(text, scan_offset) == item)
				scan_offset++
				return ascii2text(item)

	proc/Parse_VersionInfo()
		// [24] VersionInfo ::= S 'version' Eq ("'" VersionNum "'" | '"' VersionNum '"')
		scan_offset = offset
		var/string = Scan_S()
		if (!string) return

		var/version = Scan_Attribute("version")
		if (!version) return

		offset = scan_offset
		return version

	proc/Parse_EncodingDecl()
		// [80] EncodingDecl ::= S 'encoding' Eq ('"' EncName '"' | "'" EncName "'" )

		scan_offset = offset
		var/string = Scan_S()
		if (!string) return

		// [81] EncName ::= [A-Za-z] ([A-Za-z0-9._] | '-')*
		var/encoding = Scan_Attribute("encoding")
		if (!encoding) return

		offset = scan_offset
		return encoding

	proc/Parse_SDDecl()
		// [32] SDDecl ::= S 'standalone' Eq (("'" ('yes' | 'no') "'") | ('"' ('yes' | 'no') '"'))
		scan_offset = offset
		var/string = Scan_S()
		if (!string) return

		var/standalone = Scan_Attribute("standalone")
		if (!standalone) return

		offset = scan_offset
		return standalone

	proc/Parse_S()
		scan_offset = offset
		var/string = Scan_S()
		if (!string) return

		offset = scan_offset

		return new /XML/Element/Special/PCDATA(string)

	proc/Scan_S()
		// [3] S ::= (#x20 | #x9 | #xD | #xA)+
		// Decimal equivalents: (32 | 9 | 13 | 10)
		// English equivalents: (space | tab | carriage return | newline)
		var/list/chars = list(32, 9, 13, 10)
		var/string = ""
		var/char
		while(1)
			char = ScanAscii(chars)
			if (char)
				string += char
			else
				return string

	proc/Parse_Eq()
		scan_offset = offset
		var/string = Scan_Eq()
		if (!string) return

		offset = scan_offset
		return string

	proc/Scan_Eq()
		// [25] Eq ::= S? '=' S?
		var/start_offset = scan_offset
		var/first_space = Scan_S()

		var/equals = ScanText("=")
		if (!equals) goto cleanup

		var/second_space = Scan_S()
		return "[first_space][equals][second_space]"

		cleanup
		scan_offset = start_offset
		return

XML/Attribute
	var/
		name
		value

	New(my_name, my_value)
		name = my_name
		value = my_value
		return ..()


obj/test/xml/parser/verb/Scan_Reference_test()
	var/XML/Element/root = xmlRootFromString("<book><chapter>This is mine &amp; yours.</chapter></book>")
	if (root.XML() != "<book><chapter>This is mine &amp; yours.</chapter></book>") die("Got wrong text for element: [html_encode(root.XML())]")
	del(root)

obj/test/xml/parser/verb/CDATA_test()
		// [19] CDStart ::= '<![CDATA['
		// [20] CData ::= (Char* - (Char* ']]>' Char*))
		// [21] CDEnd ::= ']]>'
	var/XML/Element/root = xmlRootFromString("<root><!\[CDATA\[<example>text</example>]]></root>")
	if (root.Text() != "<example>text</example>") die("Incorrect CDATA text; got [html_encode(root.Text())]")
	if (root.XML() != "<root><!\[CDATA\[<example>text</example>]]></root>") die("Incorrect CDATA XML(); got [root.XML()]")
	del(root)

obj/test/xml/parser/verb/comment_test()
	var/XML/Element/root = xmlRootFromString("<root><!-- I have a comment! --></root>")
	if (root.XML() != "<root><!-- I have a comment! --></root>") die("Got wrong text for element: [html_encode(root.XML())]")
	del(root)


/***
 W3C XML 1.0 spec
 http://www.w3.org/TR/REC-xml

 The EBNF notation format here is explained at:
 http://www.w3.org/TR/REC-xml#Notations

[1]    document ::= prolog element Misc*
[2]    Char ::= #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
[3]    S ::= (#x20 | #x9 | #xD | #xA)+
[4]    NameChar ::= Letter | Digit | '.' | '-' | '_' | ':' | CombiningChar | Extender
[5]    Name ::= (Letter | '_' | ':') (NameChar)*
[6]    Names ::= Name (S Name)*
[7]    Nmtoken ::= (NameChar)+
[8]    Nmtokens ::= Nmtoken (S Nmtoken)*
[9]    EntityValue ::= '"' ([^%&"] | PEReference | Reference)* '"' |  "'" ([^%&'] | PEReference | Reference)* "'"
[10]   AttValue ::= '"' ([^<&"] | Reference)* '"' |  "'" ([^<&'] | Reference)* "'"
[11]   SystemLiteral ::= ('"' [^"]* '"') | ("'" [^']* "'")
[12]   PubidLiteral ::= '"' PubidChar* '"' | "'" (PubidChar - "'")* "'"
[13]   PubidChar ::= #x20 | #xD | #xA | [a-zA-Z0-9] | [-'()+,./:=?;!*#@$_%]
[14]   CharData ::= [^<&]* - ([^<&]* ']]>' [^<&]*)
[15]   Comment ::= '<!--' ((Char - '-') | ('-' (Char - '-')))* '-->'

[18]   CDSect ::= CDStart CData CDEnd
[19]   CDStart ::= '<![CDATA['
[20]   CData ::= (Char* - (Char* ']]>' Char*))
[21]   CDEnd ::= ']]>'
[22]   prolog ::= XMLDecl? Misc* (doctypedecl Misc*)?
[23]   XMLDecl ::= '<?xml' VersionInfo EncodingDecl? SDDecl? S? '?>'
[24]   VersionInfo ::= S 'version' Eq ("'" VersionNum "'" | '"' VersionNum '"')
[25]   Eq ::= S? '=' S?
[26]   VersionNum ::= ([a-zA-Z0-9_.:] | '-')+
[27]   Misc ::= Comment | PI | S
[28]   doctypedecl ::= '<!DOCTYPE' S Name (S ExternalID)? S? ('[' (markupdecl | DeclSep)* ']' S?)? '>'
		[VC: Root Element Type]
		[WFC: External Subset]
[28a]  DeclSep ::= PEReference | S
		[WFC: PE Between Declarations]
[29]   markupdecl ::= elementdecl | AttlistDecl | EntityDecl | NotationDecl | PI | Comment
		[VC: Proper Declaration/PE Nesting]
		[WFC: PEs in Internal Subset]

[32]   SDDecl ::= S 'standalone' Eq (("'" ('yes' | 'no') "'") | ('"' ('yes' | 'no') '"'))

[39]   element ::= EmptyElemTag | STag content ETag
		[WFC: Element Type Match]
		[VC: Element Valid]
[40]   STag ::= '<' Name (S Attribute)* S? '>'
		[WFC: Unique Att Spec]
[41]   Attribute ::= Name Eq AttValue
		[VC: Attribute Value Type]
		[WFC: No External Entity References]
		[WFC: No < in Attribute Values]
[42]   ETag ::= '</' Name S? '>'
[43]   content ::= CharData? ((element | Reference | CDSect | PI | Comment) CharData?)*
[44]   EmptyElemTag ::= '<' Name (S Attribute)* S? '/>'
		[WFC: Unique Att Spec]

[66]   CharRef ::= '&#' [0-9]+ ';' | '&#x' [0-9a-fA-F]+ ';'
		[WFC: Legal Character]
[67]   Reference ::= EntityRef | CharRef
[68]   EntityRef ::= '&' Name ';'
		[WFC: Entity Declared]
		[VC: Entity Declared]
		[WFC: Parsed Entity]
		[WFC: No Recursion]
[69]   PEReference ::= '%' Name ';'
		[VC: Entity Declared]
		[WFC: No Recursion]
		[WFC: In DTD]

[75]   ExternalID ::= 'SYSTEM' S SystemLiteral | 'PUBLIC' S PubidLiteral S SystemLiteral

[80]   EncodingDecl ::= S 'encoding' Eq ('"' EncName '"' | "'" EncName "'" )
[81]   EncName ::= [A-Za-z] ([A-Za-z0-9._] | '-')*
***/