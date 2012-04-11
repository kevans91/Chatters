
ServerConsole	// main controller
	New()
		..()
		// start the server managers
		ListMan  = new()
		TextMan  = new()
		BotMan   = new()
		OpMan    = new()
		ChanMan  = new()
		ChatMan  = new()
		ErrMan   = new()
		EventMan = new()
		GameMan  = new()
		HelpMan  = new()
		LogMan   = new()
		MapMan   = new()
		MsgMan   = new()
		NetMan   = new()
		PaintMan = new()

	Del()
		del(BotMan)
		del(OpMan)
		del(ChanMan)
		del(ChatMan)
		del(ErrMan)
		del(EventMan)
		del(HelpMan)
		del(LogMan)
		del(MapMan)
		del(MsgMan)
		del(NetMan)
		del(PaintMan)
		del(TextMan)
		del(ListMan)
		..()

	Topic(href, href_list[])
		if(!href_list) href_list = params2list(href)
		..()
		switch(href_list["dest"])
			if("chanman")
				ChanMan.Topic(href, href_list)
			if("chatman")
				ChatMan.Topic(href, href_list)
			if("helpman")
				HelpMan.Topic(href, href_list)
			if("msgman")
				MsgMan.Topic(href, href_list)
			if("netman")
				NetMan.Topic(href, href_list)


	proc
		Show()
			winshow(Host, "console", 1)
			winset(Host, "console.input", "focus=true;")

		Hide()
			winshow(Host, "console", 0)

		debug(T)
			#ifdef DEV_DEBUG
			if(!T) return
			var/online
			for(var/mob/M in world)
				if((M.ckey in ChanMan.devs) && M.client)
					if(!online) online = TRUE
					M << output("<font color=green>[T]", "console.output")
					winshow(M, "console", 1)
			if(!online)
				debugs = debugs || new()
				debugs += T
			#endif

		LoadCFG(cfg)
			if(!cfg || !fexists(cfg)) return

			var/list/config=new(),list/lines=new(),head
			var/txt,l,line,fchar,cbracket,phead,sep,comm,param,value

			txt = file2text(cfg)
			if(!txt || !length(txt)) return

			lines = explode(txt, "\n")
			if(!lines || !lines.len) return

			config += "main"

			for(l in lines)
				line = trim(l)
				if(!line) continue

				fchar = copytext(line, 1, 2)

				switch(fchar)
					if(";") continue

					if("#") continue

					if("\[")
						cbracket = findtext(line, "]")
						if(!cbracket) continue

						if(head)
							phead = config[config.len]
							config[phead] = head
							config += lowertext(copytext(line, 2, cbracket))
							head = null
							continue

						else if(config.len==1)
							config = new()
							config += lowertext(copytext(line, 2, cbracket))
							continue

						else
							phead = config[config.len]
							config -= phead
							config += lowertext(copytext(line, 2, cbracket))

					else
						sep = findtext(line, "=")
						if(!sep) sep = findtext(line, ":")
						if(!sep) continue

						comm = findtext(line, ";")
						if(!comm) comm = findtext(line, "#")
						if(comm && (comm < sep)) continue
						if(sep == length(line)) continue

						param = lowertext(trim(copytext(line, 1, sep)))
						value = trim(copytext(line, sep+1, comm))

						if(head) head += "&"+param
						else head = param
						head += "="+value

			if(head)
				phead = config[config.len]
				config[phead] = head

			return config
