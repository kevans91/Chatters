Settings
	Style
		proc
			UpdateColorStyle()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				var/NameColor = winget(C, "style_colors.name_color", "text")
				call(C, "SetNameColor")(NameColor)
				var/TextColor = winget(C, "style_colors.text_color", "text")
				call(C, "SetTextColor")(TextColor)
				var/Background = winget(C, "style_colors.background", "text")
				call(C, "SetBackground")(Background)
				winset(C, "style_colors.updated", "is-visible=true")
				var/save = winget(C, "style_colors.save", "is-checked")
				if(save == "true")
					C.winsize = winget(C, "default", "size")
					ChatMan.Save(C)
					winset(C, "style_colors.saved", "is-visible=true")
				sleep(50)
				if(C && C.client)
					winset(C, "style_colors.updated", "is-visible=false")
					winset(C, "style_colors.saved", "is-visible=false")


			SetDefaultColorStyle()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				C.fade_colors.len = 1
				C.fade_colors[1] = "#000000"
				C.fade_name = null
				call(C, "FadeName") ()
				call(C, "FadeColors")(1)
				call(C, "FadeNameDone") ()
				call(C, "SetNameColor")()
				call(C, "SetTextColor")()
				call(C, "SetBackground")()
				call(C, "SetShowColors")()
				winset(C, "style_colors.updated", "is-visible=true")
				var/save = winget(C, "style_colors.save", "is-checked")
				if(save == "true")
					C.winsize = winget(C, "default", "size")
					ChatMan.Save(C)
					winset(C, "style_colors.saved", "is-visible=true")
				sleep(50)
				winset(C, "style_colors.updated", "is-visible=false")
				winset(C, "style_colors.saved", "is-visible=false")

			FadeName()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				winset(C, "style_colors.define", "is-visible=false")

				winset(C, "style_colors.fade_help", "is-visible=true")
				winset(C, "style_colors.fadecolors", "is-visible=true")
				winset(C, "style_colors.colors", "is-visible=true;text=[C.fade_colors.len]")
				winset(C, "style_colors.set_colors", "is-visible=true")
				winset(C, "style_colors.done", "is-visible=true")
				for(var/i=1, i<=C.fade_colors.len, i++)
					winset(C, "style_colors.color[i]", "is-visible=true;background-color=[C.fade_colors[i]]")

			FadeColors(n as num|null)
				set hidden = 1
				if(!isnum(n)) n = text2num(winget(src, "style_colors.colors", "text"))
				var/mob/chatter/C = usr
				if(!C) return
				if(n > length(C.name)) n = length(C.name)
				C.fade_colors.len = n
				winset(C, "style_colors.colors", "is-visible=true;text=[n]")
				for(var/i=0, (i+1)<=n, i++)
					if(!C.fade_colors[i+1]) C.fade_colors[i+1] = "#000000"
					winset(C, "style_colors.color[i+1]", "is-visible=true;background-color=[C.fade_colors[i+1]]")
				for(var/i=12, i>n, i--) winset(C, "style_colors.color[i]", "is-visible=false")

			FadeNameDone()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				var/list/colors = new()
				for(var/c in C.fade_colors)
					var/red = TextMan.hex2dec(copytext(c, 2, 4))
					if(red<100) { if(red>10) {red = "0[red]"} else red = "00[red]" }
					else red = "[red]"
					var/grn = TextMan.hex2dec(copytext(c, 4, 6))
					if(grn<100) { if(grn>10) {grn = "0[grn]"} else grn = "00[grn]" }
					else grn = "[grn]"
					var/blu = TextMan.hex2dec(copytext(c, 6))
					if(blu<100) { if(blu>10) {blu = "0[blu]"} else blu = "00[blu]" }
					else blu = "[blu]"
					colors += red+grn+blu
				if(!colors || !colors.len || ((colors.len==1) && (colors[1] == "000000000")))
					if(C.name_color)
						C.fade_name = "<font color=[C.name_color]>[C.name]</font>"
					else
						C.fade_name = C.name
				else
					C.fade_name = TextMan.fadetext(C.name, colors)
				winset(C, "style_colors.fade_help", "is-visible=false")
				winset(C, "style_colors.fadecolors", "is-visible=false")
				winset(C, "style_colors.colors", "is-visible=false")
				winset(C, "style_colors.set_colors", "is-visible=false")
				winset(C, "style_colors.done", "is-visible=false")
				for(var/i=1, i<=C.fade_colors.len, i++)
					winset(C, "style_colors.color[i]", "is-visible=false")

				C << output("<b>[C.fade_name]</b>", "style_colors.output")
				winset(C, "style_colors.define", "is-visible=true")

			SetNameColor(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				if(isnull(t)) t = "#000000"
				t = "#"+ckey(t)
				if(C.fade_name == "<font color=[C.name_color]>[C.name]</font>")
					C.fade_name = null
				if(t == "#000000")
					C.name_color = null
				else
					C.name_color = uppertext(t)
				if(!C.fade_name || (C.fade_name == C.name))
					if(C.name_color)
						C.fade_name = "<font color=[C.name_color]>[C.name]</font>"
					else
						C.fade_name = C.name
					C << output("<b>[C.fade_name]</b>", "style_colors.output")
				winset(C, "style_colors.name_color_button", "background-color='[t]'")
				winset(C, "style_colors.name_color", "text='[t]'")

			SetTextColor(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "#000000"
				var/mob/chatter/C = usr
				if(!C) return
				t = "#"+ckey(t)
				if(t == "#000000")
					C.name_color = null
				else
					C.text_color = uppertext(t)
				winset(C, "style_colors.text_color_button", "background-color='[t]'")
				winset(C, "style_colors.text_color", "text='[t]'")

			SetBackground(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "#ffffff"
				var/mob/chatter/C = usr
				if(!C) return
				C.background = uppertext(t)
				winset(C, "style_colors.background_button", "background-color='[t]'")
				winset(C, "style_colors.background", "text='[C.background]'")

			SetShowColors(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "true"
				var/mob/chatter/C = usr
				if(!C) return
				if(t == "false") C.show_colors = FALSE
				else C.show_colors = TRUE