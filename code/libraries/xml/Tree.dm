#include "XML.dm"

XML/Tree
	var
		XML/Prolog/_prolog
		XML/Element/_root

	proc/Version()				// The XML version. If specified, must be "1.0".
	proc/Encoding()
//	proc/setEncoding()
	proc/Standalone()
//	proc/setStandalone()
	proc/Prolog()				// The Prolog object represents the prolog section of the document. Mostly internal.
	proc/setProlog()
	proc/Name()
	proc/SystemID()

	New(text_or_file)
		if (text_or_file)
			Parse(text_or_file)
		return ..()

	ParseFile(file)
		Parse(file2text(file))

	Parse(text_or_file)
		var/text
		if (isfile(text_or_file))
			text = file2text(text_or_file)
		else
			text = text_or_file

		_parse_document(text)

	Root()
		return _root

	setRoot(XML/Element/root)
		_root = root

	setXML(text)
		Parse(text)

	XML(pretty_print = 0)
		var/XML/Prolog/prolog = Prolog()
		var/XML/Element/root = Root()

		var/string = prolog.XML()
		string += root.XML(pretty_print = pretty_print)
		return string

	Prolog()
		return _prolog

	setProlog(XML/Prolog/prolog)
		_prolog = prolog

	Version()
		return _prolog.version

	Encoding()
		return _prolog.encoding

	Standalone()
		return _prolog.standalone

	Name()
		return _prolog.name

	SystemID()
		return _prolog.system_id

	proc/_parse_document(text)
		// [1] document ::= prolog element Misc*
		var/XML/Parser/parse = new(text)

		var/XML/Prolog/prolog = new(parse)
		if (parse.Error()) CRASH(parse.Error())

		var/XML/Element/root = parse.Parse_element()
		if (parse.Error()) CRASH(parse.Error())

		setProlog(prolog)
		setRoot(root)
