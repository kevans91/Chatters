
proc/xmlRootFromString(text)
	// Parses the text and returns the root element object.
	var/XML/Tree/twig = new(text)
	return twig.Root()

proc/xmlRootFromFile(file)
	// Parses the file and returns the root element object.
	var/XML/Tree/twig = new()
	twig.ParseFile(file)
	return twig.Root()

proc/xmlRootFromPath(path)
	/*
	 * Parses all .xml files found in the path and its subdirectories into one XML tree with
	 * a root element called "root". Each file is treated as a child of the root.
	 * The children are given an "xml_path" attribute indicating what file they were read from.
	 * If no path is specified, uses the top level path of the game.
	 */
	if (!path) path = ""
	var/XML/Element/root = xmlRootFromString("<root></root>")
	var/list/xml_files = dd_filesFromPath(path, suffix = ".xml")
	for (var/file in xml_files)
		var/XML/Element/child = xmlRootFromFile(file)
		if (child)
			child.setAttribute("file_path", file)
			root.AddChild(child)
	return root

// Possible position values when pasting in an element.
#define FIRST_CHILD	"first_child"
#define LAST_CHILD  "last_child"
#define BEFORE		"before"
#define AFTER		"after"

XML/Element/proc						// You can pass the element name and contents to new(), as in new("person", "<name>Suzy</name>")
	Tag()								// The name of the element (its "generic identifier")
	setTag(tag)

	Attribute(name)						// Returns the value for the specified attribute.
	setAttribute(name, value)			// Sets the specified attribute to the specified value.

	Attributes()						// Returns an associated list of attribute names and their values.
	setAttributes(associated_list)		// Sets the attribute list to the specified associated_list.

	Parent(optional_name)				// Returns the element's parent; if a name is provided, returns the ancestor with that name, if any.

	Descendant(optional_name)			// Returns the first child; if a name is provided, returns the first descendant with that name at any depth inside this element.
	Descendants(optional_name)			// Returns a complete list of descendants at any depth inside this element; if a name if provided, returns any descendants with that name.
	DescendantsOrSelf(optional_name)	// Includes this element in the list returned or checked.

	FirstChildElement(optional_name)	// Returns the first child that is a regular element; if a name is provided, returns the first child with that name.
	FirstChild(optional_name)			// Returns the first child element, which might be a text element/processing instruction/etc; in most cases you want FirstChildElement().
	FirstChildText(optional_name)		// Returns the text for the first child, with any internal element tags removed.

	ChildElements(optional_name)		// Returns a list of direct children that are regular elements; if a name is provided, returns any child elements with that name.
	Children(optional_name)				// Returns a list of all direct children, regardless of type of element.

	setChild(child)						// Replaces any existing children with this element.
	setChildren(list/children)			// Set the element's children to these, replacing any existing children. AddChild() is called for each.
	RemoveChildren()					// Removes all of this element's children.

	AddChild(child, position)			// Add a child element at the specified position (FIRST_CHILD, LAST_CHILD), or LAST_CHILD as the default. Removes child from any previous parent.
	RemoveChild(child)					// Remove the child from the element.

	AddSibling(sibling, position)		// Add the element as a sibling either BEFORE or AFTER this element. Defaults to AFTER.

	setText(text)						// Set the text contents of the element. This treats everything as a character, not XML, so < is translated to &lt; and such.

XML/proc
	XML()								// All text including nested element tags and enclosing tags.
	setXML(xml)							// Sets the text of the Tree or Element to the specified XML and parses the XML.

	String()							// Text including nested element tags, but without enclosing tags.

	Text()								// Text without element tags.

	WriteToFile(file)					// Writes Tree or Element to the specified file; deletes any previously existing file.


XML/Tree/proc
	Parse(text_or_file)					// Takes an XML text string or a file object containing XML text.
	ParseFile(file)						// Takes a file object or path.

	Root()								// The root element of the tree.
	setRoot()							// For internal use right now...will be public later.




XML/WriteToFile(file)
	if (fexists(file)) fdel(file)
	text2file(XML(), file)

proc/dd_filesFromPath(path, suffix)
	// Returns a list of all files in the path, including files in subdirectories.
	// If no path is provided, defaults to the game executable path.
	if (path)
		// Path must have / suffix to work, so add one if called without it.
		if (!dd_hassuffix(path, "/"))
			path += "/"
	else
		path = ""

	var/list/files = new()

	var/list/entries = flist(path)
	for (var/entry in entries)
		if (dd_hasSuffix(entry, "/"))
			files += dd_filesFromPath("[path][entry]", suffix)
		else
			if (!suffix || (suffix && dd_hassuffix(entry, suffix)))
				files += "[path][entry]"
	return files

/***

 TODO:
 	- Support reading an XML file off the web (see world.Export() doc).
 	- Add proc parameters and/or a query object to simplify searching for elements.
***/

