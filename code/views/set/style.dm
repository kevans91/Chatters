Settings
	Style
		proc
			BrowseStyle()
				set hidden = 1
				var/SetView/Set = new()
				Set.Display(src, "style")
				del(Set)

/*
		proc
			UpdateStyle()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				var/NameColor = winget(C, "style_colors.name_color", "text")
				call(C, "SetNameColor")(NameColor)
				var/TextColor = winget(C, "style_colors.text_color", "text")
				call(C, "SetTextColor")(TextColor)
				var/Background = winget(C, "style_colors.background", "text")
				call(C, "SetBackground")(Background)
				var/ChatFormat = winget(C, "style_formats.chat_format", "text")
				call(C, "SetChatFormat")(ChatFormat)
				var/EmoteFormat = winget(C, "style_formats.emote_format", "text")
				call(C, "SetEmoteFormat")(EmoteFormat)
				var/InlineEmoteFormat = winget(C, "style_formats.inline_emote_format", "text")
				call(C, "SetInlineEmoteFormat")(InlineEmoteFormat)
				var/TimeFormat = winget(C, "style_formats.time_format", "text")
				call(C, "SetTimeFormat")(TimeFormat)
				var/DateFormat = winget(C, "style_formats.date_format", "text")
				call(C, "SetDateFormat")(DateFormat)
				var/LongDateFormat = winget(C, "style_formats.long_date_format", "text")
				call(C, "SetLongDateFormat")(LongDateFormat)
				var/DefaultStyle = winget(C, "style_default.output_style", "text")
				call(C, "SetDefaultOutputStyle") (DefaultStyle)
				winset(C, "style.updated", "is-visible=true")
				var/save = winget(C, "style.save", "is-checked")
				if(save == "true")
					C.winsize = winget(C, "default", "size")
					ChatMan.Save(C)
					winset(C, "style.saved", "is-visible=true")
				sleep(50)
				if(C && C.client)
					winset(C, "style.updated", "is-visible=false")
					winset(C, "style.saved", "is-visible=false")

			SetDefaultStyle()
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
				call(C, "SetForcePunctuation")()
				call(C, "SetChatFormat")()
				call(C, "SetEmoteFormat")()
				call(C, "SetInlineEmoteFormat")()
				call(C, "SetTimeFormat")()
				call(C, "SetDateFormat")()
				call(C, "SetLongDateFormat")()
				call(C, "SetAutoAFK")()
				call(C, "SetAwayMsg")()
				call(C, "SetDefaultOutputStyle")()
				winset(C, "style.updated", "is-visible=true")
				var/save = winget(C, "style.save", "is-checked")
				if(save == "true")
					C.winsize = winget(C, "default", "size")
					ChatMan.Save(C)
					winset(C, "style.saved", "is-visible=true")
				sleep(50)
				winset(C, "style.updated", "is-visible=false")
				winset(C, "style.saved", "is-visible=false")

			FadeName()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				winset(C, "style.fadename", "is-visible=false")
				winset(C, "style.output", "is-visible=false")
				winset(C, "style.define", "is-visible=false")

				winset(C, "style.fadecolors", "is-visible=true")
				winset(C, "style.colors", "is-visible=true;text=[C.fade_colors.len]")
				winset(C, "style.set_colors", "is-visible=true")
				winset(C, "style.done", "is-visible=true")
				for(var/i=1, i<=C.fade_colors.len, i++)
					winset(C, "style.color[i]", "is-visible=true;background-color=[C.fade_colors[i]]")

			FadeColors(n as num|null)
				set hidden = 1
				if(!n) n = text2num(winget(src, "style.colors", "text"))
				var/mob/chatter/C = usr
				if(!C) return
				if(n > length(C.name)) n = length(C.name)
				C.fade_colors.len = n
				winset(C, "style.colors", "is-visible=true;text=[n]")
				for(var/i=0, (i+1)<=n, i++)
					if(!C.fade_colors[i+1]) C.fade_colors[i+1] = "#000000"
					winset(C, "style.color[i+1]", "is-visible=true;background-color=[C.fade_colors[i+1]]")
				for(var/i=12, i>n, i--) winset(C, "style.color[i]", "is-visible=false")

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
				if((colors.len==1) && (colors[1] == "000000000"))
					C.fade_name = C.name
				else
					C.fade_name = TextMan.fadetext(C.name, colors)
				winset(C, "style.fadecolors", "is-visible=false")
				winset(C, "style.colors", "is-visible=false")
				winset(C, "style.set_colors", "is-visible=false")
				winset(C, "style.done", "is-visible=false")
				for(var/i=1, i<=C.fade_colors.len, i++)
					winset(C, "style.color[i]", "is-visible=false")

				C << output("<b>[C.fade_name]</b>", "style.output")
				winset(C, "style.fadename", "is-visible=true")
				winset(C, "style.output", "is-visible=true")
				winset(C, "style.define", "is-visible=true")

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
				if(!C.fade_name)
					if(C.name_color)
						C.fade_name = "<font color=[C.name_color]>[C.name]</font>"
					else
						C.fade_name = C.name
				winset(C, "style.name_color_button", "background-color='[t]'")
				winset(C, "style.name_color", "text='[t]'")

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
				winset(C, "style.text_color_button", "background-color='[t]'")
				winset(C, "style.text_color", "text='[t]'")

			SetBackground(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "#ffffff"
				var/mob/chatter/C = usr
				if(!C) return
				C.background = uppertext(t)
				winset(C, "style.background_button", "background-color='[t]'")
				winset(C, "style.background", "text='[C.background]'")

			SetShowColors(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "true"
				var/mob/chatter/C = usr
				if(!C) return
				if(t == "false") C.show_colors = FALSE
				else C.show_colors = TRUE

			SetChatFormat(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "$ts <b>$name:</b>   $msg"
				var/mob/chatter/C = usr
				if(!C) return
				var/list/variables = list("$ts","$name","$msg","says","said")
				var/list/required = list("$name","$msg")
				C.say_format = ChatMan.ParseFormat(t, variables, required)
				winset(C, "style.chat_format", "text='[TextMan.escapeQuotes(t)]'")

			SetEmoteFormat(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "$ts $name $msg"
				var/mob/chatter/C = usr
				if(!C) return
				var/list/variables = list("$ts","$name","$msg")
				var/list/required = list("$name","$msg")
				C.me_format = ChatMan.ParseFormat(t, variables, required)
				winset(C, "style.emote_format", "text='[TextMan.escapeQuotes(t)]'")

			SetInlineEmoteFormat(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "$ts $name $rp:   $msg"
				var/mob/chatter/C = usr
				if(!C) return
				var/list/variables = list("$ts","$name","$rp","$msg","says","said")
				var/list/required = list("$name","$rp","$msg")
				C.rpsay_format = ChatMan.ParseFormat(t, variables, required)
				winset(C, "style.inline_emote_format", "text='[TextMan.escapeQuotes(t)]'")

			SetTimeFormat(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "<b>\[</b>hh:mm:ss<b>]</b>"
				var/mob/chatter/C = usr
				if(!C) return
				var/list/variables = list("hh","mm","ss")
				C.time_format = ChatMan.ParseFormat(t, variables)
				winset(C, "style.time_format", "text='[TextMan.escapeQuotes(t)]'")

			Set24HourTime(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "24"
				var/mob/chatter/C = usr
				if(!C) return
				if(t == "24")
					C._24hr_time = TRUE
					winset(C, "style.12Hour", "is-checked=false")
					winset(C, "style.24Hour", "is-checked=true")
				else
					C._24hr_time = FALSE
					winset(C, "style.12Hour", "is-checked=true")
					winset(C, "style.24Hour", "is-checked=false")
				C << output(C.ParseTime(), "style.time")

			SetTimeOffset(t as num|null)
				set hidden = 1
				if(isnull(t) || !isnum(t)) t = 0
				var/mob/chatter/C = usr
				if(!C) return
				C.time_offset = t
				C << output(C.ParseTime(), "style.time")
				winset(C, "style.offset", "text=[C.time_offset]")

			SetDateFormat(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "MMM MM, `YY"
				var/mob/chatter/C = usr
				if(!C) return
				var/list/variables = list("YYYY","YY","Month","MMM","MM","Day","DDD","DD")
				C.date_format = ChatMan.ParseFormat(t, variables)
				winset(C, "style.date_format", "text='[TextMan.escapeQuotes(t)]'")

			SetLongDateFormat(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "Day, Month DD, YYYY"
				var/mob/chatter/C = usr
				if(!C) return
				var/list/variables = list("YYYY","YY","Month","MMM","MM","Day","DDD","DD")
				C.long_date_format = ChatMan.ParseFormat(t, variables)
				winset(C, "style.long_date_format", "text='[TextMan.escapeQuotes(t)]'")

			SetAutoAFK(t as num|null)
				set hidden = 1
				if(isnull(t)) t = 15
				var/mob/chatter/C = usr
				if(!C) return
				C.auto_away = t
				winset(C, "style.auto_afk", "text='[t]'")

			SetAwayMsg(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "I have gone auto-AFK."
				var/mob/chatter/C = usr
				if(!C) return
				C.auto_reason = t
				winset(C, "style.away_msg", "text='[TextMan.escapeQuotes(t)]'")

			SetDefaultOutputStyle(t as text|null)
				set hidden = 1
				if(isnull(t)) t = ".code{color:#000000}.ident {color:#606}.comment {color:#666}.preproc {color:#008000}.keyword {color:#00f}.string {color:#0096b4}.number {color:#800000}body {text-indent: -8px;}"
				var/mob/chatter/C = usr
				if(!C) return
				C.default_output_style = t
				if(C.Chan)
					winset(C, "[ckey(Home.name)].chat.default_output", "style='[TextMan.escapeQuotes(t)]';")
				winset(C, "style.output_style", "text='[TextMan.escapeQuotes(C.default_output_style)]';")


*/