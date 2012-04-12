
mob
	chatter
		var
			name_color
			text_color
			background
			fade_name
			show_colors = TRUE

			_24hr_time  = TRUE
			time_offset = 0
			auto_away = 15
			auto_reason = "I have gone auto-AFK."

			default_output_style = ".code{color:#000000}.ident {color:#606}.comment {color:#666}.preproc {color:#008000}.keyword {color:#00f}.string {color:#0096b4}.number {color:#800000}body {text-indent: -8px;}"
			ticker = 0

			show_smileys = TRUE
			show_images = TRUE
			forced_punctuation = FALSE

			picture
			age = "No age given."
			location = "No location provided."
			description = "No description available."
			interests = "No interests supplied."

			onJoin = "me(\"enters the channel.\")"
			onQuit = "me(\"exits the channel.\")"

			filter = 2
			replacement_word = ""

			quickbar = TRUE
			showwho = TRUE
			showtopic = TRUE
			swaped_panes = FALSE
			show_title = TRUE
			show_welcome = TRUE
			show_motd = TRUE
			show_qotd = TRUE
			show_highlight = TRUE

			clear_on_reboot = FALSE
			max_output = 1000

			telnet_pass

			winsize = "640x480"

			im_sounds = TRUE
			im_volume = 100
			got_msg_snd = "./data/sndfx/mallert 010.wav"
			snt_msg_snd = "./data/sndfx/mallert 009.wav"

			// Added to notify a user if his name has been said in conversation.
			//
			name_notify = FALSE

			tmp/Painter/Painter

			tmp/OpRank/RankSelect
			tmp/OpPrivilege/PrivSelect
			tmp/obj/OpNameSelect/NameSelect
			tmp/game_color
			tmp/afk = FALSE
			tmp/telnet = FALSE
			tmp/away_at = 0
			tmp/away_reason
			tmp/spam_num
			tmp/flood_flag
			tmp/flood_num
			tmp/list/msgs
			tmp/Channel/Chan
			tmp/ColorView/CV
			tmp/MessageHandler/MsgHand

			list
				ignoring
				fade_colors = list("#000000")

				time_format = list("<b>\[</b>","hh",":","mm",":","ss","<b>]</b>")
				date_format = list("MMM"," ","MM",", `","YY")
				long_date_format = list("Day",", ","Month"," ","DD",", ","YYYY")
				say_format = list("$ts", " <b>","$name",":</b>   ","$msg")
				rpsay_format = list("$ts", " ","$name"," ","$rp",":   ","$msg")
				me_format = list("$ts", " ", "$name", " ", "$msg")

				filtered_words

				tmp/msgHandlers
				tmp/Tags = list("\[b]" = "\[/b]",
								"\[i]" = "\[/i]",
								"\[u]" = "\[/u]",
								"\[s]" = "\[/s]",
							 "\[code]" = "\[/code]")
				tmp/Smileys = list(":)",":(",":D","<:(",">:(",">:D")
				tmp/Colors = list("#C00","#0C0","#00C","#CC0","#C0C","#0CC","#000")


		New()
			..()
			MsgHand = new(src)
			CV = new(src)

		Login()
			..()

			if(!ChatMan.istelnet(key))
				winset(src, "pub_chans.grid", "current-cell=1,1;")
				src << output("<span style='background-color:#333;color:#ccc;font-weight:bold;text-align:center;'>Name:</span>", "pub_chans.grid")
				winset(src, "pub_chans.grid", "current-cell=2,1;")
				src << output("<span style='background-color:#333;color:#ccc;font-weight:bold;text-align:center;'>Founder:</span>", "pub_chans.grid")
				winset(src, "pub_chans.grid", "current-cell=3,1;")
				src << output("<span style='background-color:#333;color:#ccc;font-weight:bold;text-align:center;'>Description:</span>", "pub_chans.grid")
				winset(src, "pub_chans.grid", "current-cell=4,1;")
				src << output("<span style='background-color:#333;color:#ccc;font-weight:bold;text-align:center;'>Chatters:</span>", "pub_chans.grid")
				if(winget(src, "default", "is-maximized")=="true")
					winset(src, "default", "is-maximized=false")
				winset(src, "default", "size='484x244';")
				if(!fade_name)
					if(name_color)
						fade_name = "<font color=[name_color]>[name]</font>"
					else
						fade_name = name
				if(!gender) gender = client.gender
				if(!NetMan.HostCheck(client))
					if(Home)
						ChanMan.Join(src, Home)
					else
						winset(src, "default.output", "is-visible=true")
						winset(src, "default.child", "is-visible=false")
						src << output("Please wait while your host configures the channel...", "default.output")
						while(!Home) sleep(10)
						winset(src, "default.output", "is-visible=false")
						winset(src, "default.child", "is-visible=true")
						ChanMan.Join(src, Home)
				else if(Home)
					ChanMan.Join(src, Home)
				for(var/obj/help/topic/T in world)
					src << output("<a href='byond://?dest=helpman&action=view_topic&page=topics&target=[url_encode(T.name)]' style='color:#000000;text-decoration:none;'><img class=\"icon\" src=\"\ref[T.icon]\" iconstate=\"[T.icon_state]\">[T.name]</a>", "topics_grid.output")
				spawn() Ticker()

			// Telnet users login differently
			else
				//Set options suited for telnet.
				telnet = TRUE
				show_colors = FALSE
				show_smileys = FALSE
				show_highlight = FALSE
				onJoin = ""
				onQuit = ""

				if(!fade_name) fade_name = name
				if(!gender) gender = client.gender
				if(!NetMan.HostCheck(client))
					if(Home) ChanMan.Join(src, Home)

		Stat()
			..()
			if(src.telnet) return
			if(auto_away && (auto_away < client.inactivity/600) && !afk) afk(auto_reason)
			if(Chan && Chan.players && Chan.players.len)
				if(src in Chan.players)
					if(winget(src,"games", "is-visible")=="false")
						Chan.players -= src
						Chan.players = Chan.SortWho(Chan.players)
						GameMan.UpdateWho(Chan)
						if(afk) ReturnAFK()
			if(src.msgHandlers && src.msgHandlers.len)
				for(var/msgHandler in msgHandlers)
					var/open = winget(src, "cim_[msgHandler]", "is-visible")
					if(open == "false")
						src << output(null, "cim_[msgHandler].output")
						winset(src, "cim_[msgHandler].input", "text=")
						for(var/i=1,i<=3,i++)
							winset(src, "cim_[msgHandler].tag[i]", "is-checked=false")
						for(var/i=1,i<=7,i++)
							winset(src, "cim_[msgHandler].color[i]", "is-checked=false;text=")
							var/C = src.Colors[i]
							src.Colors[C] = null
						var/Messenger/M = msgHandlers[msgHandler]
						msgHandlers -= msgHandler
						del(M)
			if(src.Painter)
				var/open = winget(src, "map", "is-visible")
				if(open == "false")
					del(src.Painter)

		Click()
			call(usr, "LookAt")(key)


		Logout()
			if(Console && Chan) ChanMan.Quit(src, Chan)
			..()
			sleep(50)
			if(!client) del(src)