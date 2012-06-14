
HelpManager

	var
		obj/help/chapter/Main
		list
			Contents
			Topics

	New()
		..()
		LoadXML()

	Topic(href, href_list)
		..()
		var/cKey = ckey(href_list["source"])
		var/mob/chatter/M = ChatMan.Get(cKey)
		if(!M) for(var/mob/chatter/c in world)
			if(cKey == c.ckey) M = c
		if(!M) return
		switch(href_list["action"])
			if("open")
				for(var/obj/help/chapter/C in world)
					if(C.name == url_decode(href_list["target"]))
						C.open(M)
			if("close")
				for(var/obj/help/chapter/C in world)
					if(C.name == url_decode(href_list["target"]))
						C.close(M)
			if("view_topic")
				for(var/obj/help/topic/T in world)
					if(T.name == url_decode(href_list["target"]))
						T.show(M, href_list["page"])

	proc
		LoadXML()
			if(!fexists("./data/xml/help/contents.xml"))
				ErrMan.Topic("300")
				return
			var/XML/Element/contents_root = xmlRootFromFile("./data/xml/help/contents.xml")
			if(!contents_root)
				ErrMan.Topic("301")
				return
			var/XML/Element/topics_root = xmlRootFromPath("./data/xml/help/topics")
			if(!topics_root)
				ErrMan.Topic("302")
				return
			Contents = contents_root.ChildElements("chapter")
			Topics = topics_root.Descendants("topic")
			BuildContents()

		BuildContents()
			Main = new()
			Main.name = "Table of Contents"
			Main = GetContents(Main, Contents, "./data/xml/help/topics", 1)

		GetContents(obj/help/chapter/container, contents[], path)
			var/j = 1
			for(var/XML/Element/C in contents)
				var/obj/help/chapter/O = new()
				O.indent = container.indent+1
				O.name = C.Attribute("name")
				var/list/Chapters = C.ChildElements("chapter")
				if(Chapters && Chapters.len)
					O = GetContents(O, Chapters, path+"/[j]")
				var/list/topics = C.ChildElements("topic")
				var/n = 1
				for(var/XML/Element/T in topics)
					var/obj/help/topic/t = new()
					t.indent = O.indent+1
					t.name = T.Text()
					for(var/XML/Element/E in Topics)
						if(E.Attribute("file_path") == "[path]/[j]/[n].xml")
							var/XML/Element/info = E.Descendant("info")
							var/TXT = info.Text()
							if(TXT) t.Text = TXT
							break
					n++
					O.contents += t
				container.contents += O
				j++
			return container

