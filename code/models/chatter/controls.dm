
mob
	chatter
		verb
			SwapPanes(nosave as num|null)
				set hidden = 1
				if(!src.Chan) return
				if(!src.showwho) return
				src.swaped_panes ^= 1
				var/splitter = text2num(winget(src, "[ckey(Home.name)].child", "splitter"))
				winset(src, "[ckey(Home.name)].child", "splitter=[100-splitter]")
				if(src.swaped_panes)
					winset(src, "[ckey(Home.name)].child", "left='[ckey(Home.name)].who'")
					winset(src, "[ckey(Home.name)].child", "right='[ckey(Home.name)].chat'")
					winset(src, "[ckey(Home.name)].topic_label", "pos='132,0'")
					winset(src, "[ckey(Home.name)].online", "is-visible=false")
					winset(src, "[ckey(Home.name)].online_left", "is-visible=true")
				else
					winset(src, "[ckey(Home.name)].child", "left='[ckey(Home.name)].chat'")
					winset(src, "[ckey(Home.name)].child", "right='[ckey(Home.name)].who'")
					winset(src, "[ckey(Home.name)].topic_label", "pos='0,0'")
					winset(src, "[ckey(Home.name)].online", "is-visible=true")
					winset(src, "[ckey(Home.name)].online_left", "is-visible=false")
				if(!nosave)
					winsize = winget(src, "default", "size")
					ChatMan.Save(src)

			ToggleTopic(nosave as num|null)
				set hidden = 1
				if(!src.Chan) return
				if(src.showtopic)
					winset(src, "[ckey(Home.name)].topic_label", "is-visible=false")
					src.showtopic = FALSE
					if(Host == src) winset(src, "host.topic_toggle", "is-checked=false;")
					else winset(src, "menu.topic_toggle", "is-checked=false;")
					if(!showwho && !nosave)
						var/size = winget(src, "default.child", "size")
						var/X = copytext(size, 1, findtext(size, "x"))
						var/Y = text2num(copytext(size, findtext(size, "x")+1))+20
						winset(src, "default.child", "pos='0,-20';size='[X]x[Y]'")
				else
					winset(src, "[ckey(Home.name)].topic_label", "is-visible=true")
					src.showtopic = TRUE
					if(Host == src) winset(src, "host.topic_toggle", "is-checked=true;")
					else winset(src, "menu.topic_toggle", "is-checked=true;")
					if(!showwho && !nosave)
						var/size = winget(src, "default.child", "size")
						var/X = copytext(size, 1, findtext(size, "x"))
						var/Y = text2num(copytext(size, findtext(size, "x")+1))-20
						winset(src, "default.child", "pos='0,0';size='[X]x[Y]'")
				if(!nosave)
					winsize = winget(src, "default", "size")
					ChatMan.Save(src)

			ToggleWho(nosave as num|null)
				set hidden = 1
				if(!src.Chan) return
				var/pos = "right"
				if(src.swaped_panes) pos = "left"
				if(src.showwho)
					winset(src, "[ckey(Home.name)].child", "[pos]=")
					winset(src, "[ckey(Home.name)].online", "is-visible=false")
					src.showwho = FALSE
					if(Host == src) winset(src, "host.who_toggle", "is-checked=false;")
					else winset(src, "menu.who_toggle", "is-checked=false;")
					if(!showtopic)
						var/size = winget(src, "default.child", "size")
						var/X = copytext(size, 1, findtext(size, "x"))
						var/Y = text2num(copytext(size, findtext(size, "x")+1))+20
						winset(src, "default.child", "pos='0,-20';size='[X]x[Y]'")

				else
					winset(src, "[ckey(Home.name)].child", "[pos]='[ckey(Home.name)].who'")
					winset(src, "[ckey(Home.name)].online", "is-visible=true")
					src.showwho = TRUE
					if(Host == src) winset(src, "host.who_toggle", "is-checked=true;")
					else winset(src, "menu.who_toggle", "is-checked=true;")
					if(!showtopic)
						var/size = winget(src, "default.child", "size")
						var/X = copytext(size, 1, findtext(size, "x"))
						var/Y = text2num(copytext(size, findtext(size, "x")+1))-20
						winset(src, "default.child", "pos='0,0';size='[X]x[Y]'")
				if(!nosave)
					winsize = winget(src, "default", "size")
					ChatMan.Save(src)

			ToggleQuickBar(nosave as num|null)
				set hidden = 1
				if(!Chan) return
				var/i
				var/size = winget(src, "[ckey(Home.name)].child", "size")
				var/seperator = findtext(size, "x")
				var/X = copytext(size,1,seperator)
				var/Y = text2num(copytext(size,seperator+1))
				if(src.quickbar)
					Y += 16
					for(i=1, i<=5, i++)
						winset(src, "[ckey(Home.name)].tag[i]","is-visible=false")
					for(i=1, i<=6, i++)
						winset(src, "[ckey(Home.name)].smiley[i]","is-visible=false")
					for(i=1, i<=7, i++)
						winset(src, "[ckey(Home.name)].color[i]","is-visible=false")
					winset(src, "[ckey(Home.name)].toggle_quickbar", "text='+'")
					quickbar = FALSE
					if(Host == src) winset(src, "host.quickbar_toggle", "is-checked=false;")
					else winset(src, "menu.quickbar_toggle", "is-checked=false;")
				else
					Y -= 16
					for(i=1, i<=5, i++)
						winset(src, "[ckey(Home.name)].tag[i]","is-visible=true")
					for(i=1, i<=6, i++)
						winset(src, "[ckey(Home.name)].smiley[i]","is-visible=true")
					for(i=1, i<=7, i++)
						winset(src, "[ckey(Home.name)].color[i]","is-visible=true")
					winset(src, "[ckey(Home.name)].toggle_quickbar", "text='-'")
					quickbar = TRUE
					if(Host == src) winset(src, "host.quickbar_toggle", "is-checked=true;")
					else winset(src, "menu.quickbar_toggle", "is-checked=true;")
				winset(src, "[ckey(Home.name)].child", "size=[X]x[Y]")
				winset(src, "[ckey(Home.name)].default_input", "focus=true")
				if(!nosave)
					winsize = winget(src, "default", "size")
					ChatMan.Save(src)


			ToggleCIMBar(window as text|null)
				set hidden = 1
				if(!window) return
				window = "cim_[ckey(window)]"
				var/i

				var/outsize = winget(src, "[window].output", "size")
				var/outseperator = findtext(outsize, "x")
				var/outX = copytext(outsize,1,outseperator)
				var/outY = text2num(copytext(outsize,outseperator+1))

				var/profpos = winget(src, "[window].profile", "pos")
				var/profseperator = findtext(profpos, ",")
				var/profX = copytext(profpos,1,profseperator)
				var/profY = text2num(copytext(profpos,profseperator+1))

				var/showpos = winget(src, "[window].show", "pos")
				var/showseperator = findtext(showpos, ",")
				var/showX = copytext(showpos,1,showseperator)
				var/showY = text2num(copytext(showpos,showseperator+1))

				var/sharepos = winget(src, "[window].share", "pos")
				var/shareseperator = findtext(sharepos, ",")
				var/shareX = copytext(sharepos,1,shareseperator)
				var/shareY = text2num(copytext(sharepos,shareseperator+1))

				var/invpos = winget(src, "[window].invite", "pos")
				var/invseperator = findtext(invpos, ",")
				var/invX = copytext(invpos,1,invseperator)
				var/invY = text2num(copytext(invpos,invseperator+1))

				var/joinpos = winget(src, "[window].join", "pos")
				var/joinseperator = findtext(joinpos, ",")
				var/joinX = copytext(joinpos,1,joinseperator)
				var/joinY = text2num(copytext(joinpos,joinseperator+1))

				if(winget(src, "[window].tag1", "is-visible") == "true")
					outY   += 20
					profY  += 20
					showY  += 20
					shareY += 20
					invY   += 20
					joinY  += 20
					for(i=1, i<=3, i++)
						winset(src, "[window].tag[i]","is-visible=false")
					for(i=1, i<=6, i++)
						winset(src, "[window].smiley[i]","is-visible=false")
					for(i=1, i<=7, i++)
						winset(src, "[window].color[i]","is-visible=false")
					winset(src, "[window].toggle_quickbar", "text='+'")
				else
					outY   -= 20
					profY  -= 20
					showY  -= 20
					shareY -= 20
					invY   -= 20
					joinY  -= 20
					for(i=1, i<=3, i++)
						winset(src, "[window].tag[i]","is-visible=true")
					for(i=1, i<=6, i++)
						winset(src, "[window].smiley[i]","is-visible=true")
					for(i=1, i<=7, i++)
						winset(src, "[window].color[i]","is-visible=true")
					winset(src, "[window].toggle_quickbar", "text='-'")
				winset(src, "[window].profile", "pos=[profX],[profY]")
				winset(src, "[window].show", "pos=[showX],[showY]")
				winset(src, "[window].share", "pos=[shareX],[shareY]")
				winset(src, "[window].invite", "pos=[invX],[invY]")
				winset(src, "[window].join", "pos=[joinX],[joinY]")
				winset(src, "[window].output", "size=[outX]x[outY]")
				winset(src, "[window].input", "focus=true")

			NewInstantMessage()
				set hidden = 1
				var/Messenger/im = new(src)
				im.Display(src)

			ShowGameWindow()
				set hidden = 1
				winshow(src, "game", 1)

			HideGameWindow()
				set hidden = 1
				winshow(src, "game", 0)

			ShowChattersMail()
				set hidden = 1
				winshow(src, "cmail", 1)

			HideChattersMail()
				set hidden = 1
				winshow(src, "cmail", 0)

			ShowAbout()
				set hidden = 1
				winshow(src, "about", 1)

			HideAbout()
				set hidden = 1
				winshow(src, "about", 0)

			ShowCredits()
				set hidden = 1
				winshow(src, "credits", 1)

			HideCredits()
				set hidden = 1
				winshow(src, "credits", 0)

			ShowPublicChannels()
				set hidden = 1
				NetMan.UpdatePubChans(src)
				winshow(src, "pub_chans", 1)

			HidePublicChannels()
				set hidden = 1
				winshow(src, "pub_chans", 0)

			ShowHelp(t as text|null)
				set hidden = 1
				if(!t) t = "index"
				var/HelpView/HV = new()
				HV.Display(src, t)
				del(HV)
				winshow(src, "help", 1)

			HideHelp()
				set hidden = 1
				winshow(src, "help", 0)

			SearchHelp(t as text|null)
				set hidden = 1
				if(!t) t = winget(src, "help.search", "text")
				else winset(src, "help.search", "text='[t]'")
				var/HelpView/HV = new()
				HV.Display(src, "search", t)
				del(HV)

			ShowProfile()
				set hidden = 1
				src << output(null, "profile.output")
				if(src.picture) src << output("<img src='[src.picture]' width=64 height=64>\...", "profile.output")
				else
					src << output("<img src='./resources/images/noimage.png' width=64 height=64>\...", "profile.output")
				winset(src, "profile.key", "text=' [src.name]")
				winset(src, "profile.age", "text=' [src.age]")
				winset(src, "profile.gender", "text=' [src.gender]")
				winset(src, "profile.location", "text=' [src.location]")
				winset(src, "profile.description", "text=' [src.description]")
				winset(src, "profile.interests", "text=' [src.interests]")
				winset(src, "profile", "is-visible=true")
				winset(src, "profile.im_button", "command='IM \"[src.name]\"';")

			HideProfile()
				set hidden = 1
				winshow(src, "profile", 0)

			SelectColor(scope as text|null)
				set hidden = 1
				if(!scope) return
				CV.Display(scope)

			InsertColor(color as text|null, window as text|null)
				set hidden = 1
				if(!color) return
				if(!Chan) return
				var/input
				if(!window)
					window = "[ckey(Home.name)]"
					input = "default_input"
				else
					window = "cim_[ckey(window)]"
					input = "input"
				var/msg_value = winget(src, "[window].[input]", "text")
				var/down = winget(src, "[window].[color]", "is-checked")
				if(down == "false")
					msg_value += "\[/#]"
					var/index = text2num(copytext(color, 6))
					src.Colors[src.Colors[index]] = null
					winset(src, "[window].[color]", "text=''")
				else
					for(var/i=1,i<=7,i++)
						var/C = src.Colors[i]
						if(src.Colors[C] == "selected")
							msg_value += "\[/#]"
							src.Colors[C] = null
							winset(src, "[window].color[i]", "text=''")
							winset(src, "[window].color[i]", "is-checked=false")
					switch(color)
						if("color1")
							msg_value += "\[[src.Colors[1]]]"
							src.Colors[src.Colors[1]] = "selected"
						if("color2")
							msg_value += "\[[src.Colors[2]]]"
							src.Colors[src.Colors[2]] = "selected"
						if("color3")
							msg_value += "\[[src.Colors[3]]]"
							src.Colors[src.Colors[3]] = "selected"
						if("color4")
							msg_value += "\[[src.Colors[4]]]"
							src.Colors[src.Colors[4]] = "selected"
						if("color5")
							msg_value += "\[[src.Colors[5]]]"
							src.Colors[src.Colors[5]] = "selected"
						if("color6")
							msg_value += "\[[src.Colors[6]]]"
							src.Colors[src.Colors[6]] = "selected"
						if("color7")
							msg_value += "\[[src.Colors[7]]]"
							src.Colors[src.Colors[7]] = "selected"
					winset(src, "[window].[color]", "text='*'")
				winset(src, "[window].[input]", "text='[TextMan.escapeQuotes(msg_value)]'")
				winset(src, "[window].[input]", "focus=true")

			InsertTag(tag as text|null, window as text|null)
				set hidden = 1
				if(!tag) return
				if(!Chan) return
				var/input
				if(!window)
					window = "[ckey(Home.name)]"
					input = "default_input"
				else
					window = "cim_[ckey(window)]"
					input = "input"
				var/msg_value = winget(src, "[window].[input]", "text")
				var/down = winget(src, "[window].[tag]", "is-checked")
				switch(tag)
					if("tag1")
						var/open = src.Tags[1]
						if(down == "false")
							msg_value += src.Tags[open]
						else
							msg_value += open
					if("tag2")
						var/open = src.Tags[2]
						if(down == "false")
							msg_value += src.Tags[open]
						else
							msg_value += open
					if("tag3")
						var/open = src.Tags[3]
						if(down == "false")
							msg_value += src.Tags[open]
						else
							msg_value += open
					if("tag4")
						var/open = src.Tags[4]
						if(down == "false")
							msg_value += src.Tags[open]
						else
							msg_value += open
					if("tag5")
						var/open = src.Tags[5]
						if(down == "false")
							msg_value += src.Tags[open]
						else
							msg_value += open
				winset(src, "[window].[input]", "text='[TextMan.escapeQuotes(msg_value)]'")
				winset(src, "[window].[input]", "focus=true")

			InsertSmiley(smiley as text|null, window as text|null)
				set hidden = 1
				if(!smiley) return
				if(!Chan) return
				if(!window) window = "[ckey(Home.name)].default_input"
				else window = "cim_[ckey(window)].input"
				var/msg_value = winget(src, "[window]", "text")
				switch(smiley)
					if("smiley1")
						msg_value += src.Smileys[1]
					if("smiley2")
						msg_value += src.Smileys[2]
					if("smiley3")
						msg_value += src.Smileys[3]
					if("smiley4")
						msg_value += src.Smileys[4]
					if("smiley5")
						msg_value += src.Smileys[5]
					if("smiley6")
						msg_value += src.Smileys[6]
				winset(src, "[window]", "text='[TextMan.escapeQuotes(msg_value)]'")
				winset(src, "[window]", "focus=true")

			Join()
				set hidden = 1
				if(afk) ReturnAFK()
				ChanMan.Join(src, Home)

			Quit()
				set hidden = 1
				ChanMan.Quit(src, Home)

			SayAlias(msg as text|null)
				set name = ">"
				Say(msg)
