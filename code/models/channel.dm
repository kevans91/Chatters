Channel
	var
		founder
		name
		publicity
		desc
		topic
		pass
		locked
		telnet_pass
		telnet_attempts
		QOTD
		SuperNode
		MaxNodes

		// spam controls
		spam_control =1
		spam_limit = 3
		flood_limit = 3
		smileys_limit = 10
		max_msgs = 3
		min_delay = 20

		room_desc = "An average looking room."
		room_desc_size

		Bot
			chanbot
		list
			chatters
			players
			painters
			operators
			op_ranks
			op_privileges
			op_actions
			mute
			banned
			nodes
			ballots
			showcodes = list()

			filtered_words = list(	"fuck"	  =  "fudge",
									"shit"	  =  "dung",
									" ass"	  =  "donkey",
									" asshole"=  "donkeyhole",
									"penis"	  =  "pencil",
									"vagina"  =  "kitty",
									"pussy"	  =  "kitty",
									" cunt"	  =  "kitty",
									"bitch"	  =  "female dog",
									"faggot"  =  "bundle of sticks",
									" fag"	  =  "cigarette",
									"nigger"  =  "ignorant person",
									"nigga"   =  "homeslice",
									" dick"	  =  "private eye",
									" cock"	  =  "rooster",
									"cocksuck"=  "milkdrink")

	New(params[])
		if(params)
			founder = params["Founder"]
			if(!founder) founder = Host.name
			name = params["Name"]
			publicity = params["Publicity"]
			desc = params["Desc"]
			topic = params["Topic"]
			pass = params["Pass"]
			locked = text2num(params["Locked"]) ? 1 : 0
			telnet_pass = params["TelPass"]
			telnet_attempts = (text2num(params["TelAtmpts"]) || -1)
			SuperNode = text2num(params["SuperNode"]) ? 1 : 0
			MaxNodes = text2num(params["MaxNodes"])
		..()
		chanbot = new /Bot(src)
		if(SuperNode) nodes = new()

	proc
		LoadOps()
			op_ranks = OpMan.op_ranks
			var/savefile/S = new("./data/saves/channels/[ckey(name)].sav")
			var/list/ops = null
			S["operators"]  >> ops
			if(ops)
				operators = listOpen(operators)
				for(var/Name in ops)
					var/rankIndex = ops[Name]
					var/OpRank/Rank = op_ranks[rankIndex]
					operators[ckey(Name)] = new/Op(Name, Rank)

		Join(mob/chatter/C)
			if(!C || !C.client)
				del C
				return

			if(C.Chan == src) return
			C.Chan = src
			winclone(C, "channel", ckey(name))
			winclone(C, "who", "[ckey(name)].who")
			winclone(C, "chat", "[ckey(name)].chat")
			var/window = ckey(name)
			winset(C, null, "[window].default_input.is-default=true;\
							[window].chat.default_output.is-default=true;\
							[window].chat.default_output.is-disabled=false;\
							[window].topic_label.text='[TextMan.escapeQuotes(topic)]';\
							[window].child.left=[window].chat;\
							[window].child.right=[window].who;\
							default.size=[C.winsize];\
							default.can-resize=true;\
							default.title='[name] - Chatters';\
							default.menu=menu;\
							default.child.pos=0,0;\
							default.child.size=[C.winsize];\
							default.child.left=[ckey(name)];")
/*			winset(C, "[ckey(name)].default_input", "is-default=true;")
			winset(C, "[ckey(name)].chat.default_output", "is-default=true;is-disabled=false.")
			winset(C, "[ckey(name)].topic_label", "text='[TextMan.escapeQuotes(topic)]';")
			winset(C, "[ckey(name)].child", "left=[ckey(name)].chat; right=[ckey(name)].who")
			winset(C, "default", "size=[C.winsize];can-resize=true;title='[name] - Chatters';menu=menu;")
			winset(C, "default.child", "pos=0,0;size=[C.winsize];left=[ckey(name)];")
*/

			if(C.ckey in banned)
				C << output("<font color='red'>Sorry, you are banned from this channel.</font>", "[ckey(name)].chat.default_output")
				C << output("<font color='red'>Connection closed.</font>", "[ckey(name)].chat.default_output")
				del C
				return


			if(Host == C) winset(C, "default", "menu=host")

			for(var/p in typesof(/Player/proc)-/Player/proc)
				C.verbs += p

			if(C.ckey in operators)
				if(C.telnet)
					operators -= C.ckey
				else
					var/Op/O = operators[C.ckey]
					for(var/priv in O.privileges)
						var/OpPrivilege/P = OpMan.op_privileges[priv]
						C.verbs += text2path("/Operator/proc/[P.command]")

			if(!C.telnet && winget(C, "[ckey(name)].default_input", "is-disabled") == "true")
						// Returning from a kick/ban
				var/size = winget(C, "[ckey(name)].child", "size")
				var/X = copytext(size, 1, findtext(size,"x"))
				var/Y = text2num(copytext(size, findtext(size, "x")+1)) - 44
				winset(C, null, "[window].toggle_quickbar.is-visible=true;\
								[window].set.is-visible=true;\
								[window].help.is-visible=true;\
								[window].default_input.is-disabled=false;\
								[window].child.size=[X]x[Y];\
								[window].child.pos=0,0;")
				C.ToggleQuickBar(1)

			if(!C.quickbar)
				C.quickbar = TRUE
				C.ToggleQuickBar(1)
//				if(Host == C) winset(C, "host.quickbar_toggle", "is-checked=false;")
//				else winset(C, "menu.quickbar_toggle", "is-checked=false;")

			if(!C.showwho)
				C.showwho = TRUE
				C.ToggleWho(1)
				if(Host == C)
					winset(C, "host.who_toggle", "is-checked=false;")
				else
					winset(C, "menu.who_toggle", "is-checked=false;")

			if(!C.showtopic)
				C.showtopic = TRUE
				C.ToggleTopic(1)
				if(Host == C)
					winset(C, "host.topic_toggle", "is-checked=false;")
				else
					winset(C, "menu.topic_toggle", "is-checked=false;")

			if(C.swaped_panes)
				C.swaped_panes = FALSE
				C.SwapPanes(1)

			winshow(C, ckey(name), 1)

			winset(C, "[ckey(C.Chan.name)].chat.default_output", "style='[TextMan.escapeQuotes(C.default_output_style)]';max-lines='[C.max_output]';")
			if(C.show_title)
				if(C.show_colors)
					C << output({"<span style='text-align: center;'><b>[TextMan.fadetext("##########################################",list("000000000","255000000","255255255"))]</b></span>
<span style='text-align: center;'><b><font color='#0000ff'>[world.name] - Created by Xooxer</font></b></span>
<span style='text-align: center;'><b><font color='#0000ff'>and the BYOND Community</font></b></span>
<span style='text-align: center;'><b>[TextMan.fadetext("Still the greatest chat program on BYOND!", list("102000000","255000000","102000000","000000000","000000255"))]</b></span>
<span style='text-align: center;'>Source available on the <a href='http://www.github.com/kevans91/Chatters/'>Chatters Repository</a>.</span>
<span style='text-align: center;'>Copyright � 2008 Andrew "Xooxer" Arnold</span>
<span style='text-align: center;'><b>[TextMan.fadetext("##########################################",list("000000000","255000000","255255255"))]</b></span>
<span style='text-align: center;'><font color=red>- All Rights  Reserved -</font></span>
"}, "[ckey(name)].chat.default_output")

				else
					C << output({"<span style='text-align: center;'><b>##########################################</b></span>
<span style='text-align: center;'><b>[world.name] - Created by Xooxer</b></span>
<span style='text-align: center;'><b>and the BYOND Community</b></span>
<span style='text-align: center;'><b>Still the greatest chat program on BYOND!</b></span>
<span style='text-align: center;'>Source available on the <a href='http://www.github.com/kevans91/Chatters/'>Chatters Repository</a>.</span>
<span style='text-align: center;'>Copyright � 2008 Andrew "Xooxer" Arnold</span>
<span style='text-align: center;'><b>##########################################</b></span>
<span style='text-align: center;'>- All Rights  Reserved -</span>
"}, "[ckey(name)].chat.default_output")

			if(C.show_welcome)
				C << output("[time2text(world.realtime+C.time_offset, list2text(C.long_date_format))]\n<b>Welcome, [C.name]!</b>\n", "[ckey(name)].chat.default_output")

			if(C.show_motd) NetMan.MOTD(C)

			if(C.show_qotd) TextMan.QOTD(C)

			if(!chatters) chatters = new()
			chatters += C
			chatters = SortWho(chatters)

			UpdateWho()

			world.status = "[Home.name] founded by [Home.founder] - [Home.chatters.len] chatter\s"

			MapMan.Join(C)

			winset(C, "[ckey(Home.name)].default_input", "text='> ';focus=true;")

			chanbot.Say("[C.name] has joined [name]")
			chanbot.Say("You have joined [name] founded by [founder]",C)
			chanbot.Say("[topic]",C)
			if(!Home.ismute(C)) EventMan.Parse(C, C.onJoin)
			NetMan.Report("join", C.name)

		Quit(mob/chatter/C)
			if(!C)
				for(var/i=1 to chatters.len)
					if(!chatters[i]) chatters -= chatters[i]
				return
				UpdateWho()

			if(C.ckey in operators)
				var/Op/O = operators[C.ckey]
				if(O.Rank.temp) operators -= C.ckey

			if(!Home.ismute(C)) EventMan.Parse(C, C.onQuit)
			C.Chan = null

			if(chatters) chatters -= C
			if(!chatters.len) chatters = null

			UpdateWho()

			chanbot.Say("[C.name] has quit [name]")
			NetMan.Report("quit", C.name)

			if(C && ChatMan.istelnet(C.key))
				C.Logout()

		UpdateWho()

			for(var/mob/chatter/C in chatters)

				var/active = chatters.len

				if(!ChatMan.istelnet(C.key))
					for(var/i=1, i<=chatters.len, i++)
						var/mob/chatter/c = chatters[i]
						if(isnull(c))
							chatters -= chatters[i]
							continue
						if(C.client) winset(C, "[ckey(name)].who.grid", "current-cell=1,[i]")
						var/n = c.name
						if(c==C)
							if(c.afk)
								active--
								if(C.client) winset(C, "[ckey(name)].who.grid", "style='body{color:gray;font-weight:bold}'")
								c.name += " \[AFK]"
							else if(C.ckey in C.Chan.operators)
								var/Op/O = C.Chan.operators[C.ckey]
								if(C.client) winset(C, "[ckey(name)].who.grid", "style='body{color:[O.Rank.color];font-weight:bold}'")
							else
								if(C.client) winset(C, "[ckey(name)].who.grid", "style='body{font-weight:bold}'")
						else
							if(!ChatMan.istelnet(c.key) && c.afk)
								active--
								if(C.client) winset(C, "[ckey(name)].who.grid", "style='body{color:gray}'")
								c.name += " \[AFK]"
							else if(c.ckey in C.Chan.operators)
								var/Op/O = C.Chan.operators[c.ckey]
								if(C.client) winset(C, "[ckey(name)].who.grid", "style='body{color:[O.Rank.color];font-weight:bold}'")
							else
								if(C.client) winset(C, "[ckey(name)].who.grid", "style=''")
						C << output(c, "[ckey(name)].who.grid")
						c.name = n
				if(C.client)
					winset(C, "[ckey(name)].online", "text='[chatters.len] Chatter\s - [active] Active:';")
					winset(C, "[ckey(name)].online_left", "text='[chatters.len] Chatter\s - [active] Active:';")
					winset(C, "[ckey(name)].who.grid", "cells=1x[chatters.len]")

		SortWho(list/L)
			var/list/AFK
			for(var/mob/chatter/C in L)
				if(C.afk)
					if(!AFK) AFK = new
					L -= C
					AFK += C
					if(!L.len) L = null
			L = ListMan.atomSort(L)
			AFK = ListMan.atomSort(AFK)
			if(L && AFK)
				return L + AFK
			else if(AFK)
				return AFK
			else
				return L

		Say(mob/chatter/C, msg, clean, window)
			if(ismute(C))
				chanbot.Say("I'm sorry, but you appear to be muted.",C)
				return

			if(length(msg)>512)
				var/part2 = copytext(msg, 513)
				msg = copytext(msg, 1, 513)
				spawn(20) C.Say(part2)

			if(!clean)
				msg = TextMan.Sanitize(msg)
				chanbot.SpamTimer(C, msg)

			var/raw_msg = msg
			msg = TextMan.FilterChat(msg)

			var/smsg = TextMan.ParseSmileys(msg)
			smsg = TextMan.ParseLinks(smsg)

			msg = TextMan.ParseLinks(msg)

			if(!window) window = "[ckey(name)].chat.default_output"

			for(var/mob/chatter/c in chatters)
				if(c.ignoring(C) & CHAT_IGNORE) continue
				var/message
				if(!c.filter)
					message = raw_msg
					if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE)) message = TextMan.ParseSmileys(raw_msg)
					message = TextMan.ParseLinks(message)
					message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
					var/Parsedmsg = c.ParseMsg(C,message,c.say_format)
					if(Parsedmsg) c << output(Parsedmsg, "[window]")
				else if(c.filter==1)
					message = TextMan.FilterChat(raw_msg,c)
					if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE)) message = TextMan.ParseSmileys(message)
					message = TextMan.ParseLinks(message)
					message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
					var/Parsedmsg = c.ParseMsg(C,message,c.say_format)
					if(Parsedmsg) c << output(Parsedmsg, "[window]")
				else
					message = msg
					if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE))
						message = smsg
					message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
					var/Parsedmsg = c.ParseMsg(C,message,c.say_format)
					if(Parsedmsg)
						c << output(Parsedmsg, "[window]")


		Me(mob/chatter/C, msg, clean, window)
			if(ismute(C))
				chanbot.Say("I'm sorry, but you appear to be muted.",C)
				return

			if(!clean) msg = TextMan.Sanitize(msg)

			var/raw_msg = msg
			msg = TextMan.FilterChat(msg)

			var/smsg = TextMan.ParseSmileys(msg)
			smsg = TextMan.ParseLinks(smsg)

			msg = TextMan.ParseLinks(msg)
			chanbot.SpamTimer(C, msg)

			if(!window) window = "[ckey(name)].chat.default_output"

			for(var/mob/chatter/c in chatters)
				if(!c.ignoring(C))
					var/message
					if(!c.filter)
						if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE)) message = TextMan.ParseSmileys(raw_msg)
						message = TextMan.ParseLinks(message)
						message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
						var/Parsedmsg = c.ParseMsg(C,message,c.me_format, 1)
						if(Parsedmsg) c << output(Parsedmsg, "[window]")
					else if(c.filter==1)
						message = TextMan.FilterChat(raw_msg,c)
						if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE)) message = TextMan.ParseSmileys(message)
						message = TextMan.ParseLinks(message)
						message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
						var/Parsedmsg = c.ParseMsg(C,message,c.me_format, 1)
						if(Parsedmsg) c << output(Parsedmsg, "[window]")
					else
						message = msg
						if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE))
							message = smsg
						message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
						var/Parsedmsg = c.ParseMsg(C,message, c.me_format, 1)
						if(Parsedmsg)
							c << output(Parsedmsg, "[window]")

		My(mob/chatter/C, msg, clean, window)
			if(ismute(C))
				chanbot.Say("I'm sorry, but you appear to be muted.",C)
				return

			if(!clean) msg = TextMan.Sanitize(msg)

			var/raw_msg = msg
			msg = TextMan.FilterChat(msg)

			var/smsg = TextMan.ParseSmileys(msg)
			smsg = TextMan.ParseLinks(smsg)

			msg = TextMan.ParseLinks(msg)
			chanbot.SpamTimer(C, msg)

			if(!window) window = "[ckey(name)].chat.default_output"

			for(var/mob/chatter/c in chatters)
				if(!c.ignoring(C))
					var/message
					if(!c.filter)
						if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE)) message = TextMan.ParseSmileys(raw_msg)
						message = TextMan.ParseLinks(message)
						message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
						var/Parsedmsg = c.ParseMsg(C,message,c.me_format, 2)
						if(Parsedmsg) c << output(Parsedmsg, "[window]")
					else if(c.filter==1)
						message = TextMan.FilterChat(raw_msg,c)
						if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE)) message = TextMan.ParseSmileys(message)
						message = TextMan.ParseLinks(message)
						message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
						var/Parsedmsg = c.ParseMsg(C,message,c.me_format, 2)
						if(Parsedmsg) c << output(Parsedmsg, "[window]")
					else
						message = msg
						if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE))
							msg = smsg
						msg = TextMan.ParseTags(msg, c.show_colors, c.show_highlight,0)
						var/Parsedmsg = c.ParseMsg(C,msg, c.me_format, 2)
						if(Parsedmsg)
							c << output(Parsedmsg, "[window]")

		GoAFK(mob/chatter/C, msg)
			if(ChatMan.istelnet(C.key)) return
			C.afk = TRUE
			C.away_at = world.realtime
			msg = TextMan.Sanitize(msg)
			C.away_reason = msg

			var/raw_msg = msg
			msg = TextMan.FilterChat(msg)

			chatters = SortWho(chatters)
			UpdateWho()
			if(players && players.len)
				players = SortWho(players)
				GameMan.UpdateWho(src)
			if(!ismute(C))
				for(var/mob/chatter/c in chatters)
					if(!(c.ignoring(C) & CHAT_IGNORE))
						if(!c.filter)
							c << output("[c.ParseTime()] [c.show_colors ? "<font color=[C.name_color]>[C.name]</font>" : "[C.name]"] is now <b>AFK</b>. (Reason: [raw_msg])", "[ckey(name)].chat.default_output")
						else if(c.filter == 1)
							c << output("[c.ParseTime()] [c.show_colors ? "<font color=[C.name_color]>[C.name]</font>" : "[C.name]"] is now <b>AFK</b>. (Reason: [TextMan.FilterChat(raw_msg,c)])", "[ckey(name)].chat.default_output")
						else
							c << output("[c.ParseTime()] [c.show_colors ? "<font color=[C.name_color]>[C.name]</font>" : "[C.name]"] is now <b>AFK</b>. (Reason: [msg])", "[ckey(name)].chat.default_output")
			C << output("Your activity status is now set to Away From Keyboard.", "[ckey(name)].chat.default_output")


		ReturnAFK(mob/chatter/C)
			if(!C) return
			C.afk = FALSE
			C.away_reason = null
			chatters = SortWho(chatters)
			UpdateWho()
			if(players && players.len)
				players = SortWho(players)
				GameMan.UpdateWho(src)
			if(!ismute(C))
				for(var/mob/chatter/c in chatters)
					if(!(c.ignoring(C) & CHAT_IGNORE))
						c << output("[c.ParseTime()] <font color=[C.name_color]>[C.name]</font> is back from <b>AFK</b> after [round(((world.realtime - C.away_at)/600),1)] minute\s of inactivity.", "[ckey(name)].chat.default_output")
			C.away_at = null
			C << output("Your activity status is now set to Active Chatter.", "[ckey(name)].chat.default_output")


		ismute(mob/M)
			if(mute && mute.len)
				if(istext(M))
					if(ckey(M) in mute) return 1
				else if(ismob(M))
					if(M.ckey in mute) return 1
				else return 1


		TallyVotes(OpPrivilege/Priv, OpRank/Rank)
			if(!Priv) return
			var/list/votes = new()
			for(var/Ballot/B in ballots)
				if(B.privilege == Priv.name) votes += B
			if(votes.len < Priv.min_votes) return
			switch(Priv.name)
				if("Promote")
					if(!Rank) return
					var/list/nominations = new()
					for(var/Ballot/B in votes)
						var/OpRank/R = ChatMan.Rank(B.target)
						var/OpRank/TargetRank
						if(R == "All") TargetRank = op_ranks[op_ranks.len]
						else if(R.pos == 1) return
						else TargetRank = op_ranks[R.pos-1]
						if(TargetRank == Rank) nominations[B] = TargetRank
					if(nominations.len < Priv.min_votes) return
					if(Rank.max_elect)
						var/i=0
						for(var/op in operators)
							var/Op/O = operators[op]
							if(O.Rank == Rank) i++
						if(i >= Rank.max_elect)
							return
					var/list/results = new()
					for(var/Ballot/B in nominations)
						if(!(B.target in results))
							results[B.target] = 1
						else
							results[B.target] += 1
						del(B)
					for(var/R in results)
						if((results[R]*100/nominations.len) >= Priv.margin)

							var/mob/chatter/T = ChatMan.Get(R)
							if(!ismob(T)) T = null
							else if(T.telnet) return
							var/Op/Operator
							var/cKey = ckey(R)
							if(ckey(founder) == cKey) return
							if(cKey in operators)
								Operator = operators[cKey]
								var/r = op_ranks.Find(Operator.Rank)
								if(r == 1) return
								Operator.Rank = op_ranks[r-1]
								Operator.privileges = Operator.Rank.privs
								Operator.RankSelect.name = Operator.Rank.name
							else
								if(!op_ranks) return
								var/i = op_ranks.len
								var/OpRank/newRank = op_ranks[i]
								Operator = new(R, newRank)
							if(T)
								if(T.telnet) return
								for(var/priv in Operator.privileges)
									var/OpPrivilege/P = OpMan.op_privileges[priv]
									T.verbs += text2path("/Operator/proc/[P.command]")
								if(Operator.Rank.promote)
									chanbot.Say("[T.name] was elected to [Operator.Rank.name].")
								UpdateWho()
							ChanMan.SaveChan(src)
							break
				if("Demote")
					var/list/nominations = new()
					for(var/Ballot/B in votes)
						if(B.privilege == "Demote") nominations += B
					if(nominations.len < Priv.min_votes) return
					var/list/results = new()
					for(var/Ballot/B in nominations)
						if(!(B.target in results))
							results[B.target] = 1
						else
							results[B.target] += 1
						del(B)
					for(var/R in results)
						if((results[R]*100/nominations.len) >= Priv.margin)

							var/mob/chatter/T = ChatMan.Get(R)
							if(!ismob(T)) T = null
							var/cKey = ckey(R)
							if(ckey(founder) == cKey) return
							if(!(cKey in operators)) return
							var/Op/Operator = operators[cKey]
							var/r = op_ranks.Find(Operator.Rank)
							if(r == op_ranks.len)
								operators -= cKey
								if(T) chanbot.Say("[T.name] was demoted by election.")
							else
								Operator.Rank = op_ranks[r+1]
								Operator.privileges = Operator.Rank.privs
								Operator.RankSelect.name = Operator.Rank.name
								if(T)
									if(Operator.Rank.demote)
										chanbot.Say("[T.name] was demoted to [Operator.Rank.name] by election.")
							if(T)
								for(var/priv in Operator.privileges)
									var/OpPrivilege/P = OpMan.op_privileges[priv]
									T.verbs -= text2path("/Operator/proc/[P.command]")
							UpdateWho()
							ChanMan.SaveChan(src)
							break
				if("Mute")
					var/list/nominations = new()
					for(var/Ballot/B in votes)
						if(B.privilege == "Mute") nominations += B
					if(nominations.len < Priv.min_votes) return
					var/list/results = new()
					for(var/Ballot/B in nominations)
						if(!(B.target in results))
							results[B.target] = 1
						else
							results[B.target] += 1
						del(B)
					for(var/R in results)
						if((results[R]*100/nominations.len) >= Priv.margin)
							if(!mute) mute = new
							if(!(ckey(R) in mute))
								chanbot.Say("[R] has been muted by election.")
								mute += ckey(R)
							ChanMan.SaveChan(src)
							break
				if("Voice")
					var/list/nominations = new()
					for(var/Ballot/B in votes)
						if(B.privilege == "Voice") nominations += B
					if(nominations.len < Priv.min_votes) return
					var/list/results = new()
					for(var/Ballot/B in nominations)
						if(!(B.target in results))
							results[B.target] = 1
						else
							results[B.target] += 1
						del(B)
					for(var/R in results)
						if((results[R]*100/nominations.len) >= Priv.margin)
							if(mute && (ckey(R) in mute))
								mute -= ckey(R)
								chanbot.Say("[R] has been voiced by election.")
							ChanMan.SaveChan(src)
							break
				if("Kick")
					var/list/nominations = new()
					for(var/Ballot/B in votes)
						if(B.privilege == "Kick") nominations += B
					if(nominations.len < Priv.min_votes) return
					var/list/results = new()
					for(var/Ballot/B in nominations)
						if(!(B.target in results))
							results[B.target] = 1
						else
							results[B.target] += 1
						del(B)
					for(var/R in results)
						if((results[R]*100/nominations.len) >= Priv.margin)
							var/mob/chatter/C = ChatMan.Get(R)
							if(!C) return
							var/reason = "You were removed by a vote of your peers."
							chanbot.Say("[C.name] has been kicked by election.")

							if(!ChatMan.istelnet(C.key))
								// clear the chat window of everything but the output
								// to reinforce that they are really out of the program
								winset(C, "default", "menu=")
								if(C.quickbar) C.ToggleQuickBar(1)
								C << output(null, "[ckey(name)].chat.default_output")
								winset(C, "[ckey(name)].child", "right=")
								winset(C, "[ckey(name)].toggle_quickbar", "is-visible=false")
								winset(C, "[ckey(name)].set", "is-visible=false")
								winset(C, "[ckey(name)].help", "is-visible=false")
								winset(C, "[ckey(name)].default_input", "is-disabled=true")

								var/size = winget(C, "[ckey(name)].child", "size")
								var/X = copytext(size, 1, findtext(size,"x"))
								var/Y = text2num(copytext(size, findtext(size, "x")+1))+36
								winset(C, "[ckey(name)].child", "size=[X]x[Y];pos=0,0")

								C << output("You have been kicked from [name].", "[ckey(name)].chat.default_output")
								C << output("Reason: [reason]", "[ckey(name)].chat.default_output")
								C << output("<font color=red>Connection closed.", "[ckey(name)].chat.default_output")

							chatters -= C
							UpdateWho()

							C.Logout() // omgwtfpwnt
				if("Ban")
					var/list/nominations = new()
					for(var/Ballot/B in votes)
						if(B.privilege == "Ban") nominations += B
					if(nominations.len < Priv.min_votes) return
					var/list/results = new()
					for(var/Ballot/B in nominations)
						if(!(B.target in results))
							results[B.target] = 1
						else
							results[B.target] += 1
						del(B)
					for(var/R in results)
						if((results[R]*100/nominations.len) >= Priv.margin)
							var/reason = "You were removed by a vote of your peers."
							chanbot.Say("[R] has been banned by election.")

							if(!banned) banned = new

							banned += ckey(R)

							var/mob/chatter/C = ChatMan.Get(R)
							if(C)
								if(!ChatMan.istelnet(C.key))
									// clear the chat window of everything but the output
									// to reinforce that they are really out of the program
									winset(C, "default", "menu=")
									if(C.quickbar) C.ToggleQuickBar(1)
									C << output(null, "[ckey(name)].chat.default_output")
									winset(C, "[ckey(name)].child", "right=")
									winset(C, "[ckey(name)].toggle_quickbar", "is-visible=false")
									winset(C, "[ckey(name)].set", "is-visible=false")
									winset(C, "[ckey(name)].help", "is-visible=false")
									winset(C, "[ckey(name)].default_input", "is-disabled=true")

									var/size = winget(C, "[ckey(name)].child", "size")
									var/X = copytext(size, 1, findtext(size,"x"))
									var/Y = text2num(copytext(size, findtext(size, "x")+1))+44
									winset(C, "[ckey(name)].child", "size=[X]x[Y];pos=0,0")

									C << output("You have been banned from [name]", "[ckey(name)].chat.default_output")
									C << output("Reason: [reason]", "[ckey(name)].chat.default_output")
									C << output("<font color=red>Connection closed.", "[ckey(name)].chat.default_output")

								chatters -= C
								UpdateWho()

								C.Logout() // omgwtfpwnt
							ChanMan.SaveChan(src)
				if("Unban")
					var/list/nominations = new()
					for(var/Ballot/B in votes)
						if(B.privilege == "Unban") nominations += B
					if(nominations.len < Priv.min_votes) return
					var/list/results = new()
					for(var/Ballot/B in nominations)
						if(!(B.target in results))
							results[B.target] = 1
						else
							results[B.target] += 1
						del(B)
					for(var/R in results)
						if((results[R]*100/nominations.len) >= Priv.margin)
							if((ckey(R) in banned))
								chanbot.Say("[R] has been unbanned by election.")

								banned -= ckey(R)
								ChanMan.SaveChan(src)

