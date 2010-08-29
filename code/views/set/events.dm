Settings
	Events
		proc
			BrowseEvents()
				set hidden = 1
				var/SetView/Set = new()
				Set.Display(src, "events")
				del(Set)

			UpdateEvents()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				var/OnJoin = winget(C, "events.onjoin", "text")
				call(C, "SetOnJoin")(OnJoin)
				var/OnQuit = winget(C, "events.onquit", "text")
				call(C, "SetOnQuit")(OnQuit)
				call(C, "SetCIMSounds")()
				var/vol
				if(winget(C, "events.vol_low", "is-checked") == "true") vol = "low"
				else if(winget(C, "events.vol_med", "is-checked") == "true") vol = "med"
				else vol = "high"
				call(C, "SetVolume")(vol)
				winset(C, "events.updated", "is-visible=true")
				var/save = winget(C, "events.save", "is-checked")
				if(save == "true")
					C.winsize = winget(C, "default", "size")
					ChatMan.Save(C)
					winset(C, "events.saved", "is-visible=true")
				sleep(50)
				if(C && C.client)
					winset(C, "events.updated", "is-visible=false")
					winset(C, "events.saved", "is-visible=false")

			SetDefaultEvents()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				call(C, "SetOnJoin")()
				call(C, "SetOnQuit")()
				call(C, "SetCIMSounds")(1)
				call(C, "SetVolume")()
				winset(C, "events.updated", "is-visible=true")
				var/save = winget(C, "events.save", "is-checked")
				if(save == "true")
					C.winsize = winget(C, "default", "size")
					ChatMan.Save(C)
					winset(C, "events.saved", "is-visible=true")
				sleep(50)
				winset(C, "events.updated", "is-visible=false")
				winset(C, "events.saved", "is-visible=false")

			SetOnJoin(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "me(\"enters the channel.\")"
				var/mob/chatter/C = usr
				if(!C) return
				C.onJoin = t
				winset(C, "events.onjoin", "text='[TextMan.escapeQuotes(t)]'")
				C.winsize = winget(C, "default", "size")
				ChatMan.Save(C)

			SetOnQuit(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "me(\"exits the channel.\")"
				var/mob/chatter/C = usr
				if(!C) return
				C.onQuit = t
				winset(C, "events.onquit", "text='[TextMan.escapeQuotes(t)]'")
				C.winsize = winget(C, "default", "size")
				ChatMan.Save(C)

			SetCIMSounds(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				if(t)
					winset(C, "events.cim_sounds", "is-checked=true")
					C.im_sounds = TRUE
				else
					if(winget(C, "events.cim_sounds", "is-checked")=="true")
						C.im_sounds = TRUE
					else
						C.im_sounds = FALSE
				C.winsize = winget(C, "default", "size")
				ChatMan.Save(C)

			SetVolume(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "high"
				var/mob/chatter/C = usr
				if(!C) return
				switch(t)
					if("low")
						C.im_volume = 33
					if("med")
						C.im_volume = 66
					else
						C.im_volume = 100