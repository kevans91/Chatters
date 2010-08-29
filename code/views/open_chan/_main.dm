
OpenChannel
	var/browser = "open_chan_browser"
	var/list/Chans

	New()
		..()
		if(winget(usr,"open_chan", "is-visible")!="true")
			winshow(usr, "open_chan", 1)
		LoadChans()

	proc
		LoadChans()
			var/list/L = flist("./data/saves/channels/"), saved = 0
			if(L && L.len)
				if(!Chans) Chans = new()
				for(var/l in L)
					var/length = length(l)
					if(length<5) continue
					var/ext = lowertext(copytext("[l]", length-2))
					if(ext != "sav") continue
					Chans += copytext("[l]", 1, length-3)
			if(!Chans || !Chans.len)
				winset(Host, "open_chan.load_chan", "is-disabled=true")
			else
				winset(Host, "open_chan.load_chan", "is-disabled=false")
				saved = Chans.len
			winset(Host, "open_chan.status", "text='[Home ? 1 : 0] online - [saved] saved';")

		Display(page)
			var/html
			switch(page)
				if("index") html = index_html
				if("new_chan") html = new_html
				if("load_chan") html = GetLoadChanHTML()
			Host << output(html, browser)