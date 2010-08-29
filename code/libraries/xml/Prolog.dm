#include "XML.dm"

XML/Prolog
	var
		version
		encoding
		standalone

		list/elements = new()
		list/elements_2 = new()

		// DOCTYPE attributes
		name
		system_id
		public_id
		markup_text	// raw text for markupdecl stuff

	New(XML/Parser/parse)
		// [22] prolog ::= XMLDecl? Misc* (doctypedecl Misc*)?
		parse_XMLDecl(parse)

		while(1)
			var/XML/Element/element = parse.Parse_Misc()

			if (element)
				elements += element
			else
				if (parse_doctypedecl(parse))
					if (parse.Error())
						return ..()

					while(1)
						element = parse.Parse_Misc()
						if (element)
							elements_2 += element
						else
							return ..()
				else
					return ..()
		return ..()

	proc/parse_doctypedecl(XML/Parser/parse)
		// [28] doctypedecl ::= '<!DOCTYPE' S Name (S ExternalID)? S? ('[' (markupdecl | DeclSep)* ']' S?)? '>'
		// Returns 1 on success.
		var/open = parse.ParseText("<!DOCTYPE")
		if (!open) return 0

		var/space = parse.Parse_S()
		if (!space)
			parse.RegisterError("Prolog: DOCTYPE does not have a space after [html_encode("<!DOCTYPE")].")
			return

		name = parse.Parse_Name()
		if (!name)
			parse.RegisterError("Prolog: DOCTYPE does not have required name.")
			return

		parse.Parse_S()

		parse_ExternalID(parse)

		parse.Parse_S()

		// TODO/COMPLIANCE: markupdecl | DeclSep
		// Right now just treating it as raw text if it's there.
		var/bracket = parse.ParseText("\[")
		if (bracket)
			markup_text = parse.ParseTextExcluding("]")
			parse.ParseText("]")
			parse.Parse_S()

		var/close = parse.ParseText(">")
		if (!close)
			parse.RegisterError("Prolog: DOCTYPE not properly closed; expected &gt;, got [html_encode(parse.LookText())].")
			return
		return 1

	proc/parse_ExternalID(XML/Parser/parse)
		// [75] ExternalID ::= 'SYSTEM' S SystemLiteral | 'PUBLIC' S PubidLiteral S SystemLiteral
		var/id_type = parse.ParseText(list("SYSTEM", "PUBLIC"))
		if (!id_type) return

		var/space = parse.Parse_S()
		if (!space)
			parse.RegisterError("Prolog: Required space after SYSTEM or PUBLIC is missing.")
			return

		switch(id_type)
			if ("SYSTEM")
				system_id = parse.Parse_SystemLiteral()

			if ("PUBLIC")
				public_id = parse.Parse_PubidLiteral()
				space = parse.Parse_S()
				if (!space)
					parse.RegisterError("Prolog: Required space after PubidLiteral is missing.")
					return

				system_id = parse.Parse_SystemLiteral()

	proc/parse_XMLDecl(XML/Parser/parse)
		// [23] XMLDecl ::= '<?xml' VersionInfo EncodingDecl? SDDecl? S? '?>'

		// Tag opening, which must be at start of document.
		var/prefix = parse.ParseText("<?xml")
		if (!prefix) return

		version = parse.Parse_VersionInfo()
		if (!version || version != "1.0")
			parse.RegisterError("Prolog: Required version attribute missing or set incorrectly: [version]. If a prolog (?xml) is specified, it must contain version=\"1.0\".")
			return
		if (!version) version = "1.0"

		encoding = parse.Parse_EncodingDecl()
		// Fix for Piratehead: Be looser about encoding; we were rejecting iso-8859-1 which will work fine.
		// So we'll just assume that DM can handle whatever encoding is thrown at us.
//		if (encoding && encoding != "UTF-8" && encoding != "UTF-16")
//			parse.RegisterError("Prolog: Unsupported encoding: [encoding]")
//			return

		standalone = parse.Parse_SDDecl()
		if (standalone && standalone != "yes")
			parse.RegisterError("Prolog: 'standalone = [standalone]' is not supported by the XML library at this time.")

		parse.Parse_S()

		var/closing = parse.ParseText("?>")
		if (!closing)
			parse.RegisterError("Prolog: The prolog (?xml) is not closed correctly.")
		return

	XML()
		var/XMLDecl = ""
		if (version) XMLDecl += "version=\"[version]\""
		if (encoding) XMLDecl += " encoding=\"[encoding]\""
		if (standalone) XMLDecl += " standalone=\"[standalone]\""
		if (XMLDecl) XMLDecl = "<?xml [XMLDecl] ?>"

		var/Misc_1 = ""
		for (var/XML/Element/element in elements)
			Misc_1 += element.XML()

		var/doctypedecl = ""
		if (name) doctypedecl += "[name] "
		if (public_id) doctypedecl += "PUBLIC [public_id] [system_id] "
		else if (system_id) doctypedecl += "SYSTEM [system_id] "
		if (markup_text) doctypedecl += "\[[markup_text]]"
		if (doctypedecl) doctypedecl = "<!DOCTYPE [doctypedecl]>"

		var/Misc_2 = ""
		for (var/XML/Element/element in elements_2)
			Misc_2 += element.XML()

		return "[XMLDecl][Misc_1][doctypedecl][Misc_2]"


obj/test/xml/prolog/verb/parse_doctypedecl_test()
	// SYSTEM
	var/XML/Tree/twig = new("<!DOCTYPE titlepage SYSTEM \"http://www.foo.bar/dtds/typo.dtd\" \[<!ENTITY % active.links \"INCLUDE\">]><root></root>")
	if (twig.Name() != "titlepage") die("DOCTYPE should indicate name \"titlepage\"; got \"[twig.Name()]\"")

	if (twig.XML() != "<!DOCTYPE titlepage SYSTEM \"http://www.foo.bar/dtds/typo.dtd\" \[<!ENTITY % active.links \"INCLUDE\">]><root/>") die("Prolog returned wrong text: [html_encode(twig.XML())]")

	var/XML/Element/root = twig.Root()
	if (!root || root.Tag() != "root") die("Document with DOCTYPE returned incorrect root element.")

	// \n after DOCTYPE was causing error.
	root = xmlRootFromString({"<!DOCTYPE server_status SYSTEM "http://www.camelotherald.com/mythic.dtd">\n<root></root>"})
	if (!root) die("Did not get root element from string with Mythic doctype.")
	del(root)

	// PUBLIC
	// Piratehead provided this XML which was failing to parse: Prolog: Required space after PubidLiteral is missing.
	twig = new({"<!DOCTYPE character PUBLIC "-//rpgprofiler.net//DTD 3EProfiler 1.0//EN" "http://www.rpgprofiler.net/2003/3EProfiler.dtd"><root></root>"})
	root = twig.Root()
	del(root)
