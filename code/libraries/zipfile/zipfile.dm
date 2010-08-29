
zipfile
	var
		name
		contents[]

	proc
		Open(name)
			if(name) src.name = name
			return ..() //handled internally by byondlib
		Close()
			return ..()
		Export(path,name_in_zip)
			return ..()
		Import(path,name_in_zip)
			return ..()
		Remove(name_in_zip)
			return ..()
		ClearContents()
			return ..()
		Flist(prefix)  //behaves like flist() but operates within zipfile

	//internal stuff
	_dm_interface = 129
	var/tmp/_binobj


zipfile/New(name)
	if(name) Open(name)
	return ..()

zipfile/proc
	FindFinal(haystack,needle)
		var/pos
		var/pos2
		do
			pos = pos2
			pos2 = findtext(haystack,needle,pos+1)
		while(pos2)
		return pos
	PathPartTerminated(F) // path1/path2/file --> path1/path2/
		var/pos = FindFinal(F,"/")
		if(pos) return copytext(F,1,pos+1)
	FilePart(F) // path1/path2/file --> file
		var/pos = FindFinal(F,"/")
		return copytext(F,pos+1)

zipfile/Flist(prefix)
	var/retlist[0]
	var/prefix_path = PathPartTerminated(prefix)
	var/prefix_length = length(prefix)
	var/prefix_path_length = length(prefix_path)

	for(var/F in contents)
		if(findtext(F,prefix,1,prefix_length+1))
			var/end = findtext(F,"/",prefix_path_length+1)
			if(end) end++
			F = copytext(F,prefix_path_length+1,end)
			if(F && !(F in retlist)) retlist += F

	return retlist
