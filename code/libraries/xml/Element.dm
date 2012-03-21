#include "XML.dm"

XML/Element
	var
		_tag
		XML/Element/_parent
		_attributes_params			// For space/efficiency, store attributes as a params list.
		list/_children

	New(tag, text)
		if (tag) setTag(tag)
		if (text) setXML(text)
		return ..()

	Del()
		_parent = null

		if (_children)
			for (var/child in _children)
				del(child)
			_children = null

		return ..()

	Tag()
		return _tag

	setTag(tag)
		_tag = tag

	Parent(optional_name)
		var/XML/Element/parent = _parent
		if (optional_name)
			while(parent && parent.Tag() != optional_name)
				parent = parent.Parent()
		return parent

	proc/_setParent(XML/Element/parent)
		_parent = parent

	Descendant(optional_name)
		// Equivalent to Twig's next_elt function.
		if (!optional_name)
			return FirstChild()

		for (var/XML/Element/child in Children())
			if (child.Tag() == optional_name) return child

			var/XML/Element/descendant = child.Descendant(optional_name)
			if (descendant) return descendant

	Descendants(optional_name)
		var/list/descendants = new()
		for (var/XML/Element/child in Children())
			descendants += child.DescendantsOrSelf(optional_name)
		return descendants

	DescendantsOrSelf(optional_name)
		var/list/descendants = new()
		if (!optional_name || Tag() == optional_name)
			descendants += src

		descendants += Descendants(optional_name)
		return descendants

	Attributes()
		if (_attributes_params)
			return params2list(_attributes_params)

		// No params, so return an empty list.
		var/list/placeholder = new()
		return placeholder

	setAttributes(list/attributes)
		_attributes_params = list2params(attributes)

	Attribute(name)
		var/list/attributes = Attributes()
		return attributes[name]

	setAttribute(name, value)
		var/list/attributes = Attributes()
		attributes[name] = value
		setAttributes(attributes)

	FirstChild(optional_name, element_only)
		var/list/children
		if (element_only)
			children = ChildElements()
		else
			children = Children()

		if (!children) return

		if (!optional_name) return children[1]

		// Look for the specified name.
		for (var/XML/Element/child in children)
			if (child.Tag() == optional_name)
				return child

	FirstChildElement(optional_name)
		return FirstChild(optional_name, element_only = 1)

	FirstChildText(optional_name)
		var/XML/Element/child = FirstChild(optional_name)
		if (child) return child.Text()

	Children(optional_name, elements_only)
		// If given a name, only return children named that.
		// If elements_only is specified, only return non-text elements.
		if (_children)
			if (optional_name)
				var/list/named = new()
				for (var/XML/Element/child in _children)
					if (child.Tag() == optional_name)
						named += child
				return named
			else if (elements_only)
				var/list/elements = new()
				for (var/XML/Element/child in _children)
					if (!dd_hasPrefix(child.Tag(), "#"))
						elements += child
				return elements
		else
			// If no children, return an empty list.
			var/list/placeholder = new()
			return placeholder

		// We have children and no modifiers were passed in, so return children.
		return _children

	setChild(XML/Element/child)
		var/list/children = list(child)
		setChildren(children)

	setChildren(list/children)
		RemoveChildren()

		for (var/XML/Element/child in children)
			AddChild(child)

	AddChild(XML/Element/child, position = LAST_CHILD)
		// Remove from any previous parent.
		var/XML/Element/child_parent = child.Parent()
		if (child_parent)
			child_parent.RemoveChild(child)
		child._setParent(src)

		if (!_children) _children = new()

		switch(position)
			if (LAST_CHILD)		_children += child
			if (FIRST_CHILD)	_children.Insert(1, child)
		return

	RemoveChildren()
		if (_children)
			for (var/XML/Element/child in _children)
				RemoveChild(child)

	RemoveChild(XML/Element/child)
		if (_children && _children.Find(child))
			child._setParent(null)
			_children -= child

	ChildElements(optional_name)
		return Children(optional_name, elements_only = 1)

	AddSibling(XML/Element/sibling, position = AFTER)
		var/XML/Element/parent = Parent()
		if (!parent) CRASH("Can't add sibling to [Tag()] because there is no parent.")

		var/list/siblings = parent.Children()
		var/my_position = siblings.Find(src)
		if (!my_position) CRASH("[Tag()] couldn't find itself listed in parent's children.")

		var/XML/Element/sibling_parent = sibling.Parent()
		if (sibling_parent) sibling_parent.RemoveChild(sibling)
		sibling._setParent(parent)

		switch(position)
			if (BEFORE) siblings.Insert(my_position, sibling)
			if (AFTER)	siblings.Insert(my_position + 1, sibling)

	setText(text)
		// Translate <>&"' to their entity equivalents.
		// Must replace & first to keep from messing up entities.
		var/newtext = dd_replacetext(text, "&", "&amp;")
		newtext = dd_replacetext(newtext, "<", "&lt;")
		newtext = dd_replacetext(newtext, ">", "&gt;")
//		newtext = dd_replacetext(newtext, "\"", "&quot;")
//		newtext = dd_replacetext(newtext, "\'", "&apos;")

		var/XML/Element/Special/PCDATA/pc = new(newtext)
		setChild(pc)

	Text(escaped)
		var/content = ""
		for (var/XML/Element/child in Children())
			content += child.Text()

		if (!escaped)
			content = dd_replacetext(content, "&lt;", "<")
			content = dd_replacetext(content, "&gt;", ">")
//			content = dd_replacetext(content, "&quot;", "\"")
//			content = dd_replacetext(content, "&apos;", "\'")
			content = dd_replacetext(content, "&amp;", "&")
		return content

	setXML(text)
		var/XML/Parser/parse = new(text)
		var/list/children = parse.Parse_content()
		if (parse.Error()) CRASH(parse.Error())
		setChildren(children)

	XML(pretty_print = 0, indent_level = 0, enclosing_tags = 1)
		var/content = ""
		var/child_pretty_print = pretty_print
		var/child_indent = indent_level + 1

		if (pretty_print)
			// If any of my children are text nodes, don't use indentation for my children.
			for (var/XML/Element/child in Children())
				if (child.Tag() == "#PCDATA")
					child_pretty_print = 0

		for (var/XML/Element/child in Children())
			content += child.XML(pretty_print = child_pretty_print, indent_level = child_indent)

		if (!enclosing_tags)
			return content

		// Opening tag.
		var/newline = ""
		var/indent = ""
		if (pretty_print && indent_level)
			newline = "\n"
			for (var/count = 0, count < indent_level, count++)
				indent += "    "

		var/string = "[newline][indent]<[Tag()]"
		var/list/attributes = Attributes()
		for (var/attribute in attributes)
			var/value = attributes[attribute]

			// Delimeter can be " or ' depending on whether the value uses one of those characters.
			var/delimiter = "\""
			if (findtextEx(value, "\"")) delimiter = "'"

			string += " [attribute]=[delimiter][value][delimiter]"

		// Is this an empty element?
		if (!content)
			string += "/>"
			return string

		string += ">"

		// Content
		string += content

		// Closing tag
		if (pretty_print)
			if (indent_level == 0)
				// Handle the root level closing tag.
				newline = "\n"
			else if (!child_pretty_print)
				// If children not being indented, then don't newline/indent.
				newline = ""
				indent = ""
		string += "[newline][indent]</[Tag()]>"
		return string

	String(pretty_print)
		return XML(pretty_print = pretty_print, enclosing_tags = 0)

XML/Element/Special
	var
		_text

	Text()
		return _text

	setXML(text)
		_text = text

	XML(enclosing_tags, pretty_print, indent_level)
		return Text()

XML/Element/Special/PCDATA
	New(text)
		return ..("#PCDATA", text)

XML/Element/Special/CDATA
	New(text)
		return ..("#CDATA", text)

	XML(enclosing_tags, pretty_print, indent_level)
		return "<!\[CDATA\[[Text()]]]>"

XML/Element/Special/Comment
	New(text)
		return ..("#COMMENT", text)

	XML(enclosing_tags, pretty_print, indent_level)
		return "<!--[Text()]-->"

XML/Element/Special/PI


obj/test/xml/element/verb/Attributes_test()
	var/XML/Element/root = xmlRootFromString({"<root position="top" empty=""></root>"})
	if (root.Attribute("position") != "top") die({"Attribute() did not return correct value "top"."})

	var/list/attributes = root.Attributes()
	if (!attributes.Find("empty") || root.Attribute("empty") != "") die({"Attribute() didn't handle empty attribute value correctly."})

	root = xmlRootFromString({"<root></root>"})
	if (root.Attribute("position")) die({"Attribute shouldn't have returned value for position."})

	root.setAttribute("first", "1")
	if (root.Attribute("first") != "1") die({"setAttribute() did not set first=1."})

	root.setAttribute("second", "2")
	if (root.XML() != {"<root first="1" second="2"/>"}) die ({"setAttribute() didn't handle multiple attributes correctly: [root.XML()]"})
	del(root)

obj/test/xml/element/verb/Parent_test()
	var/XML/Element/root = xmlRootFromString("<grandfather><father><son/></father></grandfather>")
	var/XML/Element/son = root.Descendant("son")
	var/XML/Element/father = son.Parent()
	if (father.Tag() != "father") die("Parent() should be \"father\"; got [father.Tag()].")

	var/XML/Element/grandfather = son.Parent("grandfather")
	if (grandfather.Tag() != "grandfather") die("Parent() should be \"grandfather\"; got [grandfather.Tag()].")
	del(root)

obj/test/xml/element/verb/Descendant_test()
	var/XML/Element/root = xmlRootFromString("<grandfather><father><son/></father></grandfather>")
	var/XML/Element/child = root.Descendant("son")
	if (!child || child.Tag() != "son") die("Descendant() did not return correct element.")
	del(root)

obj/test/xml/element/verb/Descendants_test()
	var/XML/Element/root = xmlRootFromString("<book><section><chapter/><chapter/></section></book>")
	var/list/items = root.Descendants("chapter")
	if (items.len != 2) die("Should have 2 descendants; got [items.len].")

	items = root.Descendants()
	if (items.len != 3) die("Should have 3 descendants; got [items.len].")
	del(root)

obj/test/xml/element/verb/Text_test()
	var/XML/Element/root = xmlRootFromString("<root></root>")
	var/text = {"This is not XML and these should be escaped: <>&"}
	root.setText(text)
	if (root.Text(escaped = 1) != "This is not XML and these should be escaped: &lt;&gt;&amp;") die("setText()/Text(1) returned incorrectly escaped text:\n[html_encode(root.Text(escaped = 1))]")
	if (root.Text() != {"This is not XML and these should be escaped: <>&"}) die("Text() did not return raw characters:\n[html_encode(root.Text())]")
	del(root)

obj/test/xml/element/verb/XML_test()
	var/XML/Element/root = xmlRootFromString({"<book isbn="12" title = "mine"><chapter>chapter <number>1</number></chapter><section>section</section></book>"})
	var/text = root.XML()
	if (text != {"<book isbn="12" title="mine"><chapter>chapter <number>1</number></chapter><section>section</section></book>"}) die("XML() returned wrong value:\n[html_encode(text)]")
	del(root)

	root = xmlRootFromString("<root><child><subchild>text <i>inline</i></subchild></child></root>")
	text = root.XML(pretty_print = 1)
	if (text != "<root>\n    <child>\n        <subchild>text <i>inline</i></subchild>\n    </child>\n</root>") die("XML(pretty_print=1) returned wrong value:\n[html_encode(text)]")
	del(root)

obj/test/xml/element/verb/String_test()
	var/XML/Element/root = xmlRootFromString("<book isbn=\"12\" title = \"mine\"><chapter>chapter <number>1</number></chapter><section>section</section></book>")
	var/text = root.String()
	if (text != "<chapter>chapter <number>1</number></chapter><section>section</section>") die("String() returned wrong value:\n[html_encode(text)]")
	del(root)

obj/test/xml/element/verb/Children_test()
	var/XML/Element/root = xmlRootFromString("<book><chapter>chapter <number>1</number></chapter><section>section</section></book>")
	var/list/children = root.Children()
	if (children.len != 2) die("Root element should have 2 children; has [children.len].")

	var/XML/Element/chapter = children[1]
	children = chapter.Children()
	if (children.len != 2) die("Chapter element should have 2 children; has [children.len].")

	var/XML/Element/new_child = new("part", "Second part")
	root.setChild(new_child)
	if (root.XML() != "<book><part>Second part</part></book>") die("setChild() did not set &lt;part&gt; correctly as the child: [root.XML()]")

	new_child = new("part", "First part")
	root.AddChild(new_child, FIRST_CHILD)
	if (root.XML() != "<book><part>First part</part><part>Second part</part></book>") die("setChild() did not add &lt;part&gt; correctly as the FIRST_CHILD: [root.XML()]")
	del(root)

obj/test/xml/element/verb/addChild_test()
	var/XML/Element/root = xmlRootFromString("<grandfather><father><son/></father></grandfather>")
	var/XML/Element/son = root.Descendant("son")
	root.AddChild(son)
	if (son.Parent() != root) die("AddChild() should make grandfather the parent: got [root.Tag()].")
	del(root)

obj/test/xml/element/verb/addSibling_test()
	var/XML/Element/root = xmlRootFromString("<father><daughter/><granddaughter/><son/></father>")
	var/XML/Element/granddaughter = root.FirstChild("granddaughter")
	var/XML/Element/son = root.FirstChild("son")
	granddaughter.AddSibling(son, BEFORE)
	if (root.XML() != "<father><daughter/><son/><granddaughter/></father>") die("AddSibling() should put son after daughter: got [root.XML()].")
	del(root)

obj/test/xml/element/verb/FirstChildElement_test()
	var/XML/Element/root = xmlRootFromString("<book><chapter>This is my <number>first</number> chapter.</chapter></book>")
	var/XML/Element/chapter = root.FirstChild("chapter")
	var/XML/Element/number = chapter.FirstChildElement()
	if (number.Tag() != "number") die("Got wrong element for FirstChildElement(): [number.Tag()]")
	del(root)

obj/test/xml/element/verb/FirstChild_test()
	var/XML/Element/root = xmlRootFromString("<book><chapter>This is my chapter.</chapter><section>This is my section.</section></book>")
	var/XML/Element/child = root.FirstChild()
	if (!child) die("FirstChild should be \"chapter\"; got no first child.")
	if (child.Tag() != "chapter") die("child should be \"chapter\"; got: [child.Tag()]")
	if (child.Text() != "This is my chapter.") die("Got wrong text for child: [child.Text()]")

	child = root.FirstChild("section")
	if (child.Tag() != "section") die("child should be \"section\"; got [child.Tag()]")
	if (child.Text() != "This is my section.") die("Got wrong text for child: [child.Text()]")

	var/text = root.FirstChildText("section")
	if (text != "This is my section.") die("Got wrong FirstChildText(): [text]")
	del(root)
