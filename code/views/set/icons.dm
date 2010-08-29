Settings
	Icons
		proc
			BrowseIcons()
				set hidden = 1
				var/SetView/Set = new()
				Set.Display(src, "icons")
				del(Set)

			UpdateIcons()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				if(winget(C, "icons.show_smileys", "is-checked")=="true")
					call(C, "SetShowSmileys")(1)
				else call(C, "SetShowSmileys")()
				if(winget(C, "icons.show_images", "is-checked")=="true")
					call(C, "SetShowImages")(1)
				else call(C, "SetShowImages")()
				winset(C, "icons.updated", "is-visible=true")
				var/save = winget(C, "icons.save", "is-checked")
				if(save == "true")
					C.winsize = winget(C, "default", "size")
					ChatMan.Save(C)
					winset(C, "icons.saved", "is-visible=true")
				sleep(50)
				winset(C, "icons.updated", "is-visible=false")
				winset(C, "icons.saved", "is-visible=false")

			SetDefaultIcons()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				call(C, "SetShowSmileys")(1)
				call(C, "SetShowImages")(1)
				winset(C, "icons.updated", "is-visible=true")
				var/save = winget(C, "icons.save", "is-checked")
				if(save == "true")
					C.winsize = winget(C, "default", "size")
					ChatMan.Save(C)
					winset(C, "icons.saved", "is-visible=true")
				sleep(50)
				if(C && C.client)
					winset(C, "icons.updated", "is-visible=false")
					winset(C, "icons.saved", "is-visible=false")

			SetShowSmileys(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				if(t)
					winset(C, "icons.show_smileys", "is-checked=true")
					C.show_smileys = TRUE
				else
					if(winget(C, "icons.show_smileys", "is-checked")=="true")
						C.show_smileys = TRUE
					else
						C.show_smileys = FALSE

			SetShowImages(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				if(t)
					winset(C, "icons.show_images", "is-checked=true")
					C.show_images = TRUE
				else
					if(winget(C, "icons.show_images", "is-checked")=="true")
						C.show_images = TRUE
					else
						C.show_images = FALSE