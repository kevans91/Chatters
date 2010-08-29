Settings
	Style
		proc
			UpdateCSSStyle()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				var/DefaultStyle = winget(C, "style_default.output_style", "text")
				call(C, "SetDefaultOutputStyle") (DefaultStyle)
				winset(C, "style_default.updated", "is-visible=true")
				var/save = winget(C, "style_default.save", "is-checked")
				if(save == "true")
					C.winsize = winget(C, "default", "size")
					ChatMan.Save(C)
					winset(C, "style_default.saved", "is-visible=true")
				sleep(50)
				if(C && C.client)
					winset(C, "style_default.updated", "is-visible=false")
					winset(C, "style_default.saved", "is-visible=false")

			SetDefaultCSSStyle()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				call(C, "SetDefaultOutputStyle")()
				winset(C, "style_default.updated", "is-visible=true")
				var/save = winget(C, "style_default.save", "is-checked")
				if(save == "true")
					C.winsize = winget(C, "default", "size")
					ChatMan.Save(C)
					winset(C, "style_default.saved", "is-visible=true")
				sleep(50)
				winset(C, "style_default.updated", "is-visible=false")
				winset(C, "style_default.saved", "is-visible=false")

			SetDefaultOutputStyle(t as text|null)
				set hidden = 1
				if(isnull(t)) t = ".code{color:#000000}.ident {color:#606}.comment {color:#666}.preproc {color:#008000}.keyword {color:#00f}.string {color:#0096b4}.number {color:#800000}body {text-indent: -8px;}"
				var/mob/chatter/C = usr
				if(!C) return
				C.default_output_style = t
				if(C.Chan)
					winset(C, "[ckey(Home.name)].chat.default_output", "style='[TextMan.escapeQuotes(t)]';")
				winset(C, "style_default.output_style", "text='[TextMan.escapeQuotes(C.default_output_style)]';")
