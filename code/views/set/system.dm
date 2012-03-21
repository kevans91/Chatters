Settings
	System
		proc
			BrowseSystem()
				set hidden = 1
				var/SetView/Set = new()
				Set.Display(src, "system")
				del(Set)

			UpdateSystem()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				call(C, "SetShowTitle")()
				call(C, "SetShowWelcome")()
				call(C, "SetShowMotD")()
				call(C, "SetShowQotD")()
				call(C, "SetClearOnReboot")()
				var/maxout = winget(C, "system.max_output", "text")
				call(C, "SetMaxOutput")(maxout)
				call(C, "SetHighlightCode")()
				var/tnpswd = winget(C, "system.telnet_pass", "text")
				call(C, "SetTelnetPassword")(tnpswd)
				var/X = winget(C, "system.win_size_x", "text")
				call(C, "SetWinSizeX")(X)
				var/Y = winget(C, "system.win_size_y", "text")
				call(C, "SetWinSizeY")(Y)
				if(C.Chan) winset(C, "default", "size=[C.winsize]")
				var/TimeOffset = winget(C, "system.offset", "text")
				call(C, "SetTimeOffset")(text2num(TimeOffset))
				var/AutoAFK = text2num(winget(C, "system.auto_afk", "text"))
				call(C, "SetAutoAFK")(AutoAFK)
				var/AwayMsg = winget(C, "system.away_msg", "text")
				call(C, "SetAwayMsg")(AwayMsg)
				winset(C, "system.updated", "is-visible=true")
				var/save = winget(C, "system.save", "is-checked")
				if(save == "true")
					C.winsize = winget(C, "default", "size")
					ChatMan.Save(C)
					winset(C, "system.saved", "is-visible=true")
				sleep(50)
				if(C && C.client)
					winset(C, "system.updated", "is-visible=false")
					winset(C, "system.saved", "is-visible=false")

			SetDefaultSystem()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				call(C, "SetShowTitle")(1)
				call(C, "SetShowWelcome")(1)
				call(C, "SetShowMotD")(1)
				call(C, "SetShowQotD")(1)
				call(C, "SetClearOnReboot")("false")
				call(C, "SetMaxOutput")("1000")
				call(C, "SetHighlightCode")(1)
				call(C, "SetTelnetPassword")()
				call(C, "SetWinSizeX")()
				call(C, "SetWinSizeY")()
				call(C, "Set24HourTime")()
				call(C, "SetTimeOffset")()
				call(C, "SetAutoAFK")()
				call(C, "SetAwayMsg")()
				winset(C, "system.updated", "is-visible=true")
				var/save = winget(C, "system.save", "is-checked")
				if(save == "true")
					C.winsize = winget(C, "default", "size")
					ChatMan.Save(C)
					winset(C, "system.saved", "is-visible=true")
				sleep(50)
				winset(C, "system.updated", "is-visible=false")
				winset(C, "system.saved", "is-visible=false")

			SetShowTitle(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				if(t)
					winset(C, "system.show_title", "is-checked=true")
					C.show_title = TRUE
				else
					if(winget(C, "system.show_title", "is-checked")=="true")
						C.show_title = TRUE
					else
						C.show_title = FALSE

			SetShowWelcome(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				if(t)
					winset(C, "system.show_welcome", "is-checked=true")
					C.show_welcome = TRUE
				else
					if(winget(C, "system.show_welcome", "is-checked")=="true")
						C.show_welcome = TRUE
					else
						C.show_welcome = FALSE

			SetShowMotD(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				if(t)
					winset(C, "system.show_motd", "is-checked=true")
					C.show_motd = TRUE
				else
					if(winget(C, "system.show_motd", "is-checked")=="true")
						C.show_motd = TRUE
					else
						C.show_motd = FALSE

			SetShowQotD(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				if(t)
					winset(C, "system.show_qotd", "is-checked=true")
					C.show_qotd = TRUE
				else
					if(winget(C, "system.show_qotd", "is-checked")=="true")
						C.show_qotd = TRUE
					else
						C.show_qotd = FALSE

			SetClearOnReboot(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				if(t)
					winset(C, "system.clear_reboot", "is-checked=true")
					C.clear_on_reboot = FALSE
				else
					if(winget(C, "system.clear_reboot", "is-checked")=="true")
						C.clear_on_reboot = TRUE
					else
						C.clear_on_reboot = FALSE

			SetMaxOutput(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				t = text2num(t)
				if(t<0) t = 0
				C.max_output = t
				winset(C, "system.max_output", "text='[C.max_output]';")
				if(Home) winset(C, "[ckey(Home.name)].chat.default_output", "max-lines='[C.max_output]';")

			SetHighlightCode(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				if(t)
					winset(C, "system.show_highlight", "is-checked=true")
					C.show_highlight = TRUE
				else
					if(winget(C, "system.show_highlight", "is-checked")=="true")
						C.show_highlight = TRUE
					else
						C.show_highlight = FALSE

			SetTelnetPassword(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				var/list/L = new()
				var/telnet_key = md5(C.key)
				var/savefile/S = new("./data/saves/tel.net")
				if(t)
					var/telnet_pass = md5(t)
					C.telnet_pass = t
					if(S && length(S))
						S["telnet"] >> L
					if(!telnet_key in L) L += telnet_key
					L[telnet_key] = telnet_pass
					S["telnet"] << L
				else if(S && length(S))
					if(!telnet_key in L) return
					L[telnet_key] = null
					S["telnet"] << L

			SetWinSizeX(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				var/X,Y=480
				t = text2num(t)
				if(t<=0) t = 640
				X = t
				if(C.winsize)
					Y = copytext(C.winsize, findtext(C.winsize, "x")+1)
				C.winsize = "[X]x[Y]"
				winset(C, "system.win_size_x", "text='[X]';")

			SetWinSizeY(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				var/Y,X=640
				t = text2num(t)
				if(t<=0) t = 480
				Y = t
				if(C.winsize)
					X = copytext(C.winsize, 1, findtext(C.winsize, "x"))
				C.winsize = "[X]x[Y]"
				winset(C, "system.win_size_y", "text='[Y]';")

			Set24HourTime(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "24"
				var/mob/chatter/C = usr
				if(!C) return
				if(t == "24")
					C._24hr_time = TRUE
					winset(C, "system.12Hour", "is-checked=false")
					winset(C, "system.24Hour", "is-checked=true")
				else
					C._24hr_time = FALSE
					winset(C, "system.12Hour", "is-checked=true")
					winset(C, "system.24Hour", "is-checked=false")
				C << output(TextMan.strip_html(C.ParseTime()), "system.time")

			SetTimeOffset(t as num|null)
				set hidden = 1
				if(isnull(t) || !isnum(t)) t = 0
				var/mob/chatter/C = usr
				if(!C) return
				C.time_offset = t
				C << output(TextMan.strip_html(C.ParseTime()), "system.time")
				winset(C, "system.offset", "text=[C.time_offset]")

			SetAutoAFK(t as num|null)
				set hidden = 1
				if(isnull(t)) t = 15
				var/mob/chatter/C = usr
				if(!C) return
				C.auto_away = t
				winset(C, "system.auto_afk", "text='[t]'")

			SetAwayMsg(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "I have gone auto-AFK."
				var/mob/chatter/C = usr
				if(!C) return
				C.auto_reason = t
				winset(C, "system.away_msg", "text='[TextMan.escapeQuotes(t)]'")