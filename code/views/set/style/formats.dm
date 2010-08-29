Settings
	Style
		proc
			UpdateFormatStyle()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
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
				winset(C, "style_formats.updated", "is-visible=true")
				var/save = winget(C, "style_formats.save", "is-checked")
				if(save == "true")
					C.winsize = winget(C, "default", "size")
					ChatMan.Save(C)
					winset(C, "style_formats.saved", "is-visible=true")
				sleep(50)
				if(C && C.client)
					winset(C, "style_formats.updated", "is-visible=false")
					winset(C, "style_formats.saved", "is-visible=false")

			SetDefaultFormatStyle()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				call(C, "SetForcePunctuation")()
				call(C, "SetNameNotify")()
				call(C, "SetChatFormat")()
				call(C, "SetEmoteFormat")()
				call(C, "SetInlineEmoteFormat")()
				call(C, "SetTimeFormat")()
				call(C, "SetDateFormat")()
				call(C, "SetLongDateFormat")()
				winset(C, "style_formats.updated", "is-visible=true")
				var/save = winget(C, "style_format.save", "is-checked")
				if(save == "true")
					C.winsize = winget(C, "default", "size")
					ChatMan.Save(C)
					winset(C, "style_formats.saved", "is-visible=true")
				sleep(50)
				winset(C, "style_formats.updated", "is-visible=false")
				winset(C, "style_formats.saved", "is-visible=false")

			SetForcePunctuation(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "false"
				var/mob/chatter/C = usr
				if(!C) return
				if(t == "true") C.forced_punctuation = TRUE
				else C.forced_punctuation = FALSE

			SetNameNotify(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "false"
				var/mob/chatter/C = usr
				if(!C) return
				if(t == "true") C.name_notify = TRUE
				else C.name_notify = FALSE

			SetChatFormat(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "$ts <b>$name:</b>   $msg"
				var/mob/chatter/C = usr
				if(!C) return
				var/list/variables = list("$ts","$name","$msg","says","said")
				var/list/required = list("$name","$msg")
				C.say_format = ChatMan.ParseFormat(t, variables, required)
				winset(C, "style_formats.chat_format", "text='[TextMan.escapeQuotes(t)]'")

			SetEmoteFormat(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "$ts $name $msg"
				var/mob/chatter/C = usr
				if(!C) return
				var/list/variables = list("$ts","$name","$msg")
				var/list/required = list("$name","$msg")
				C.me_format = ChatMan.ParseFormat(t, variables, required)
				winset(C, "style_formats.emote_format", "text='[TextMan.escapeQuotes(t)]'")

			SetInlineEmoteFormat(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "$ts $name $rp:   $msg"
				var/mob/chatter/C = usr
				if(!C) return
				var/list/variables = list("$ts","$name","$rp","$msg","says","said")
				var/list/required = list("$name","$rp","$msg")
				C.rpsay_format = ChatMan.ParseFormat(t, variables, required)
				winset(C, "style_formats.inline_emote_format", "text='[TextMan.escapeQuotes(t)]'")

			SetTimeFormat(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "<b>\[</b>hh:mm:ss<b>]</b>"
				var/mob/chatter/C = usr
				if(!C) return
				var/list/variables = list("hh","mm","ss")
				C.time_format = ChatMan.ParseFormat(t, variables)
				winset(C, "style_formats.time_format", "text='[TextMan.escapeQuotes(t)]'")

			SetDateFormat(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "MMM MM, `YY"
				var/mob/chatter/C = usr
				if(!C) return
				var/list/variables = list("YYYY","YY","Month","MMM","MM","Day","DDD","DD")
				C.date_format = ChatMan.ParseFormat(t, variables)
				winset(C, "style_formats.date_format", "text='[TextMan.escapeQuotes(t)]'")

			SetLongDateFormat(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "Day, Month DD, YYYY"
				var/mob/chatter/C = usr
				if(!C) return
				var/list/variables = list("YYYY","YY","Month","MMM","MM","Day","DDD","DD")
				C.long_date_format = ChatMan.ParseFormat(t, variables)
				winset(C, "style_formats.long_date_format", "text='[TextMan.escapeQuotes(t)]'")
