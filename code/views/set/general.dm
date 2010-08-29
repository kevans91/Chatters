Settings
	General
		proc
			BrowseGeneral()
				set hidden = 1
				var/SetView/Set = new()
				Set.Display(src, "general")
				del(Set)

			UpdateGeneral()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				var/Picture = winget(C, "general.picture", "text")
				call(C, "SetPicture")(Picture)
				var/Age = winget(C, "general.age", "text")
				call(C, "SetAge")(Age)
				var/Location = winget(C, "general.location", "text")
				call(C, "SetLocation")(Location)
				var/Description = winget(C, "general.description", "text")
				call(C, "SetDescription")(Description)
				var/Interests = winget(C, "general.interests", "text")
				call(C, "SetInterests")(Interests)
				winset(C, "general.updated", "is-visible=true")
				var/save = winget(C, "general.save", "is-checked")
				if(save == "true")
					C.winsize = winget(C, "default", "size")
					ChatMan.Save(C)
					winset(C, "general.saved", "is-visible=true")
				sleep(50)
				if(C && C.client)
					winset(C, "general.updated", "is-visible=false")
					winset(C, "general.saved", "is-visible=false")

			SetDefaultGeneral()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				call(C, "SetPicture")()
				call(C, "SetAge")()
				call(C, "SetGender")()
				winset(C, "general.neuter", "is-checked=true")
				winset(C, "general.male", "is-checked=false")
				winset(C, "general.female", "is-checked=false")
				winset(C, "general.plural", "is-checked=false")
				call(C, "SetLocation")()
				call(C, "SetDescription")()
				call(C, "SetInterests")()
				winset(C, "general.updated", "is-visible=true")
				var/save = winget(C, "general.save", "is-checked")
				if(save == "true")
					C.winsize = winget(C, "default", "size")
					ChatMan.Save(C)
					winset(C, "general.saved", "is-visible=true")
				sleep(50)
				winset(C, "general.updated", "is-visible=false")
				winset(C, "general.saved", "is-visible=false")

			SetPicture(t as text|null)
				set hidden = 1
				if(isnull(t)) t = ""
				var/mob/chatter/C = usr
				if(!C) return
				C.picture = t
				winset(C, "general.picture", "text='[t]'")

			SetAge(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "No age given."
				var/mob/chatter/C = usr
				if(!C) return
				C.age = t
				winset(C, "general.age", "text='[TextMan.escapeQuotes(t)]'")

			SetGender(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "neuter"
				var/mob/chatter/C = usr
				if(!C) return
				var/list/genders = list("male"=MALE,"female"=FEMALE,"neuter"=NEUTER,"plural"=PLURAL)
				if(t in genders) C.gender = genders[t]

			SetLocation(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "No location provided."
				var/mob/chatter/C = usr
				if(!C) return
				C.location = t
				winset(C, "general.location", "text='[TextMan.escapeQuotes(t)]'")

			SetDescription(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "No description available."
				var/mob/chatter/C = usr
				if(!C) return
				C.description = t
				winset(C, "general.description", "text='[TextMan.escapeQuotes(t)]'")

			SetInterests(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "No interests supplied."
				var/mob/chatter/C = usr
				if(!C) return
				C.interests = t
				winset(C, "general.interests", "text='[TextMan.escapeQuotes(t)]'")
