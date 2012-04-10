
Bot
	var
		name = "@ChanBot"
		name_color = "#f00"
		text_color
		fade_name = "<font color=#f00>@ChanBot</font>"
		Channel/Chan

	New(Channel/chan)
		..()
		if(chan) Chan = chan

	verb
		echo(msg as text|null)
			set hidden = 1
			if(!msg) return
			Home.chanbot.Say(msg, null, 1)

		echome(msg as text|null)
			set hidden = 1
			if(!msg) return
			Home.chanbot.Me(msg, 1)

		echomy(msg as text|null)
			set hidden = 1
			if(!msg) return
			Home.chanbot.My(msg, 1)

		edit(cmd as text|null)
			set hidden = 1
			var/space, variable, end, value

			do
				space = findtext(cmd, " ")
				variable = lowertext(copytext(cmd, 1, space))
				if(!space) break
				end = findtext(cmd, ";")
				value = copytext(cmd, space+1, end)
			while(end)

			switch(variable)
				if("name")
					if(value) Home.chanbot.SetName(value,1)
					usr << output("<font color=#090>@edit:</font> <font color=#900>Bot</font> name [Home.chanbot.name]", "console.output")
				if("name-color")
					if(value) Home.chanbot.SetNameColor(value,1)
					usr << output("<font color=#090>@edit:</font> <font color=#900>Bot</font> name-color [(Home.chanbot.name_color | "#000")]", "console.output")
				if("text-color")
					if(value) Home.chanbot.SetTextColor(value,1)
					usr << output("<font color=#090>@edit:</font> <font color=#900>Bot</font> text-color [(Home.chanbot.text_color | "#000")]", "console.output")
				if("spam-control")
					if(value) Home.chanbot.SetSpamControl(text2num(value),1)
					usr << output("<font color=#090>@edit:</font> <font color=#009>Chan</font> spam-control [(Home.spam_control ? Home.spam_control : "0")]", "console.output")
				if("spam-limit")
					if(value) Home.chanbot.SetSpamLimit(text2num(value),1)
					usr << output("<font color=#090>@edit:</font> <font color=#009>Chan</font> spam-limit [(Home.spam_limit ? Home.spam_limit : "0")]", "console.output")
				if("flood-limit")
					if(value) Home.chanbot.SetFloodLimit(text2num(value),1)
					usr << output("<font color=#090>@edit:</font> <font color=#009>Chan</font> flood-limit [(Home.flood_limit ? Home.flood_limit : "0")]", "console.output")
				if("smileys-limit")
					if(value) Home.chanbot.SetSmileysLimit(text2num(value),1)
					usr << output("<font color=#090>@edit:</font> <font color=#009>Chan</font> smileys-limit [(Home.smileys_limit ? Home.smileys_limit : "0")]", "console.output")
				if("max-msgs")
					if(value) Home.chanbot.SetMaxMsgs(text2num(value),1)
					usr << output("<font color=#090>@edit:</font> <font color=#009>Chan</font> max-msgs [(Home.max_msgs ? Home.max_msgs : "0")]", "console.output")
				if("min-delay")
					if(value) Home.chanbot.SetMinDelay(text2num(value),1)
					usr << output("<font color=#090>@edit:</font> <font color=#009>Chan</font> min-delay [(Home.min_delay ? Home.min_delay : "0")]", "console.output")
				if("publicity")
					if(value) Home.chanbot.SetPublicity(value,1)
					usr << output("<font color=#090>@edit:</font> <font color=#009>Chan</font> publicity [Home.publicity]", "console.output")
				if("desc")
					if(value) Home.chanbot.SetDesc(value,1)
					usr << output("<font color=#090>@edit:</font> <font color=#009>Chan</font> desc [Home.desc]", "console.output")
				if("topic")
					if(value) Home.chanbot.SetTopic(value,1)
					usr << output("<font color=#090>@edit:</font> <font color=#009>Chan</font> topic [Home.topic]", "console.output")
				if("pass")
					if(value) Home.chanbot.SetPass(value,1)
					usr << output("<font color=#090>@edit:</font> <font color=#009>Chan</font> pass [Home.pass]", "console.output")
				if("locked")
					if(value) Home.chanbot.SetLocked(value,1)
					usr << output("<font color=#090>@edit:</font> <font color=#009>Chan</font> locked [(Home.locked ? Home.locked : "0")]", "console.output")
				if("room-desc")
					if(value) Home.chanbot.SetRoomDesc(value, 1)
					usr << output("<font color=#090>@edit:</font> <font color=#009>Chan</font> room-desc [Home.room_desc]", "console.output")
				else usr << output({"<font color=#090>@edit:</font>
	name - <font color=#900>Bot name</font>
	name-color - <font color=#900>Bot name color hex</font>
	text-color - <font color=#900>Bot text color hex</font>
	spam-control - <font color=#009>Chan spam controls active 0 | 1</font>
	spam-limit - <font color=#009>Chan spam limit number</font>
	flood-limit - <font color=#009>Chan flood limit number</font>
	smileys-limit - <font color=#009>Chan smileys limit number</font>
	max-msgs - <font color=#009>Chan max messages number</font>
	min-delay - <font color=#009>Chan minimum delay number</font>
	publicity - <font color=#009>Chan publicity public | private | invisible</font>
	desc - <font color=#009>Chan decription</font>
	topic - <font color=#009>Chan topic</font>
	pass - <font color=#009>Chan password</font>
	locked - <font color=#009>Chan locked 0 | 1</font>"}, "console.output")
			winshow(usr, "console", 1)


		ViewLog()
			set hidden = 1
			if(!LogMan.logfile || !fexists("./data/saves/logs/log.txt"))
				usr << output("No log file exists.", "consoloe.output")
				return
			else
				usr << browse("<title>Chatters Error Log (log.txt)</title><pre>[file2text("./data/saves/logs/log.txt")]</pre>", "window=error_log")

		GetLog()
			set hidden = 1
			if(!LogMan.logfile || !fexists("./data/saves/logs/log.txt"))
				usr << output("No log file exists.", "consoloe.output")
				return
			else
				usr << ftp("./data/saves/logs/log.txt")

		ClearLog()
			set hidden = 1
			if(!LogMan.logfile || !fexists("./data/saves/logs/log.txt"))
				usr << output("No log file exists.", "consoloe.output")
				return
			else
				world.log = null
				fdel("./data/saves/logs/log.txt")
				world.log = file("./data/saves/logs/log.txt")
				usr << output("Error Log cleared successfully.", "console.output")
			winshow(usr, "console", 1)

		Reboot(msg as text|null)
			set hidden = 1
			usr << output("Rebooting...", "console.output")
			sleep(10)
			if(Home)
				if(!msg) msg = "A reboot will take place in 15 seconds..."
				var/announcement = {"<center><br><br><br><b>[TextMan.fadetext("#################### --- Attention! --- ####################",list("255255255","255000000","255255255"))]<br>
[TextMan.fadetext("A Reboot has been initiated by [usr.name]: ",list("000000000","255000000","000000000"))]</b><br>
[TextMan.fadetext("----------------------------------------------------------------------------------------------------------",list("255255255","000000000","255255255"))]<br>
<pre>[msg]</pre><br>
[TextMan.fadetext("_____________________ \[end of announcement\] _____________________",list("255255255","000000000","255255255"))]
<br><br>"}
				var/no_color = {"<center><br><br><br><b>#################### --- Attention! --- ####################<br>
A Reboot has been initiated by  [usr.name]: </b><br>
----------------------------------------------------------------------------------------------------------<br>
<pre>[msg]</pre><br>
_____________________ \[end of announcement\] _____________________
<br><br>"}
				for(var/mob/chatter/C in Home.chatters)
					if(C.show_colors)
						C << output(announcement, "[ckey(Home.name)].chat.default_output")
					else
						C << output(no_color, "[ckey(Home.name)].chat.default_output")
				ChanMan.SaveChan(Home)
				BotMan.SaveBot(Home.chanbot)
			sleep(150)
			for(var/mob/chatter/C in world)
				if(!C.telnet && C.clear_on_reboot)
					if(Home) C << output(,"[ckey(Home.name)].chat.default_output")
					C << output(,"default.output")
					C << output(,"console.output")
			sleep(10)
			world.Reboot()


	proc
		Say(msg, mob/chatter/C, echoed)

			if(length(msg)>512)
				var/part2 = copytext(msg, 513)
				msg = copytext(msg, 1, 513)
				spawn(20) Say(part2, C)

			msg = TextMan.Sanitize(msg)

			var/raw_msg = msg
			msg = TextMan.FilterChat(msg)

			var/smsg = TextMan.ParseSmileys(msg)
			smsg = TextMan.ParseLinks(smsg)

			msg = TextMan.ParseLinks(msg)
			if(echoed)
				if(name_color)
					fade_name = "<font color=[name_color]>>[copytext(name, 2)]</font>"
				else
					fade_name = ">[copytext(name, 2)]"
			if(C)
				var/message
				if(!C.filter)
					message = msg
					if(C.show_smileys) message = TextMan.ParseSmileys(raw_msg)
					message = TextMan.ParseLinks(message)
					message = TextMan.ParseTags(message, C.show_colors, C.show_highlight,0)
					C << output(C.ParseMsg(src, msg, C.say_format),"[ckey(Chan.name)].chat.default_output")
				else if(C.filter==1)
					message = TextMan.FilterChat(raw_msg,C)
					if(C.show_smileys) message = TextMan.ParseSmileys(message)
					message = TextMan.ParseLinks(message)
					message = TextMan.ParseTags(message, C.show_colors, C.show_highlight,0)
					var/Parsedmsg = C.ParseMsg(src,message,C.say_format)
					if(Parsedmsg) C << output(Parsedmsg, "[ckey(Chan.name)].chat.default_output")
				else
					message = msg
					if(C.show_smileys) message = smsg
					message = TextMan.ParseTags(message, C.show_colors, C.show_highlight,0)
					var/Parsedmsg = C.ParseMsg(src,message,C.say_format)
					if(Parsedmsg) C << output(Parsedmsg, "[ckey(Chan.name)].chat.default_output")
			else
				for(var/mob/chatter/c in Chan.chatters)
					var/message
					if(!c.filter)
						message = msg
						if(c.show_smileys)  message = TextMan.ParseSmileys(raw_msg)
						message = TextMan.ParseLinks(message)
						message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
						c << output(c.ParseMsg(src, message, c.say_format),"[ckey(Chan.name)].chat.default_output")
					else if(c.filter==1)
						message = TextMan.FilterChat(raw_msg,c)
						if(c.show_smileys)  message = TextMan.ParseSmileys(message)
						message = TextMan.ParseLinks(message)
						message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
						c << output(c.ParseMsg(src, message, c.say_format),"[ckey(Chan.name)].chat.default_output")
					else
						message = msg
						if(c.show_smileys)  message = smsg
						message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
						c << output(c.ParseMsg(src, message, c.say_format),"[ckey(Chan.name)].chat.default_output")
			if(echoed)
				if(name_color)
					fade_name = "<font color=[name_color]>[name]</font>"
				else
					fade_name = "[name]"

		GameSay(msg, window)
			if(!window) return
			if(length(msg)>512)
				var/part2 = copytext(msg, 513)
				msg = copytext(msg, 1, 513)
				spawn(20) GameSay(part2, window)

			msg = TextMan.Sanitize(msg)

			var/smsg = TextMan.ParseSmileys(msg)
			smsg = TextMan.ParseLinks(smsg)

			msg = TextMan.ParseLinks(msg)
			for(var/mob/chatter/c in Chan.chatters)
				var/message = msg
				if(c.show_smileys) message = smsg
				message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
				c << output(c.ParseMsg(src, message, c.say_format),"[window].output")

		Me(msg, echoed)
			msg = TextMan.Sanitize(msg)

			var/raw_msg = msg
			msg = TextMan.FilterChat(msg)

			var/smsg = TextMan.ParseSmileys(msg)
			smsg = TextMan.ParseLinks(smsg)

			msg = TextMan.ParseLinks(msg)
			if(echoed) name = ">[copytext(name, 2)]"
			for(var/mob/chatter/c in Chan.chatters)
				var/message
				if(!c.filter)
					if(c.show_smileys) message = TextMan.ParseSmileys(raw_msg)
					message = TextMan.ParseLinks(message)
					message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
					c << output(c.ParseMsg(src, message, c.me_format,1),"[ckey(Chan.name)].chat.default_output")
				else if(c.filter == 1)
					message = TextMan.FilterChat(raw_msg,c)
					if(c.show_smileys) message = TextMan.ParseSmileys(message)
					message = TextMan.ParseLinks(message)
					message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
					c << output(c.ParseMsg(src, message, c.me_format,1),"[ckey(Chan.name)].chat.default_output")
				else
					message = msg
					if(c.show_smileys) message = smsg
					message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
					c << output(c.ParseMsg(src, message, c.me_format,1),"[ckey(Chan.name)].chat.default_output")
			if(echoed) name = "@[copytext(name, 2)]"

		My(msg, echoed)
			msg = TextMan.Sanitize(msg)

			var/raw_msg = msg
			msg = TextMan.FilterChat(msg)

			var/smsg = TextMan.ParseSmileys(msg)
			smsg = TextMan.ParseLinks(smsg)

			msg = TextMan.ParseLinks(msg)
			if(echoed) name = ">[copytext(name, 2)]"
			for(var/mob/chatter/c in Chan.chatters)
				var/message
				if(!c.filter)
					if(c.show_smileys) message = TextMan.ParseSmileys(raw_msg)
					message = TextMan.ParseLinks(message)
					message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
					c << output(c.ParseMsg(src, message, c.me_format,2),"[ckey(Chan.name)].chat.default_output")
				else if(c.filter == 1)
					message = TextMan.FilterChat(raw_msg,c)
					if(c.show_smileys) message = TextMan.ParseSmileys(message)
					message = TextMan.ParseLinks(message)
					message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
					c << output(c.ParseMsg(src, message, c.me_format,2),"[ckey(Chan.name)].chat.default_output")
				else
					message = msg
					if(c.show_smileys) message = smsg
					message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
					c << output(c.ParseMsg(src, message, c.me_format,2),"[ckey(Chan.name)].chat.default_output")
			if(echoed) name = "@[copytext(name, 2)]"


		SetName(newName,save)
			if(!newName) newName = "ChanBot"
			name = "@"+newName
			fade_name = "<font color=[name_color]>[name]</font>"
			if(save) BotMan.SaveBot(src)


		SetNameColor(newColor,save)
			if(!newColor) newColor = "#f00"
			if((newColor == "#000") || (newColor == "#000000"))
				name_color = null
			else
				name_color = newColor
			if(name_color)
				fade_name = "<font color=[name_color]>[name]</font>"
			if(save) BotMan.SaveBot(src)


		SetTextColor(newColor,save)
			if(!newColor) newColor = "#000"
			if((newColor == "#000") || (newColor == "#000000"))
				text_color = null
			else
				text_color = newColor
			if(save) BotMan.SaveBot(src)


		SetSpamControl(newValue,save)
			Chan.spam_control = newValue
			if(save) ChanMan.SaveChan(src.Chan)


		SetSpamLimit(newValue,save)
			Chan.spam_limit = newValue
			if(save) ChanMan.SaveChan(src.Chan)


		SetFloodLimit(newValue,save)
			Chan.flood_limit = newValue
			if(save) ChanMan.SaveChan(src.Chan)


		SetSmileysLimit(newValue,save)
			Chan.smileys_limit = newValue
			if(save) ChanMan.SaveChan(src.Chan)


		SetMaxMsgs(newValue,save)
			Chan.max_msgs = newValue
			if(save) ChanMan.SaveChan(src.Chan)


		SetMinDelay(newValue,save)
			Chan.min_delay = newValue
			if(save) ChanMan.SaveChan(src.Chan)


		SetPublicity(newValue,save)
			world << "Setting publicity to [newValue]"
			switch(newValue)
				if("public")
					Chan.publicity = newValue
					world.visibility = 1
				if("private")
					Chan.publicity = newValue
					world.visibility = 0
				if("invisible")
					Chan.publicity = newValue
					world.visibility = 0
			if(save) ChanMan.SaveChan(src.Chan)


		SetDesc(newValue,save)
			Chan.desc = newValue
			if(save) ChanMan.SaveChan(src.Chan)


		SetTopic(newValue,save)
			Chan.topic = newValue
			for(var/mob/chatter/C in Chan.chatters)
				if(ChatMan.istelnet(C.key)) continue
				if(!C.client) continue
				winset(C, "[ckey(Chan.name)].topic_label", "text='[TextMan.escapeQuotes(newValue)]';")
			if(save) ChanMan.SaveChan(src.Chan)


		SetPass(newValue,save)
			Chan.pass = newValue
			if(save) ChanMan.SaveChan(src.Chan)


		SetLocked(newValue,save)
			Chan.locked = newValue
			if(save) ChanMan.SaveChan(src.Chan)

		SetRoomDesc(newValue,save)
			call(usr, "RoomDesc")(newValue)
			if(save) ChanMan.SaveChan(src.Chan)


		SpamTimer(mob/chatter/C, msg)
			if(!C || !C.Chan || !Chan.spam_control || (C==Host)) return
			if((++C.flood_num) > Chan.max_msgs) C.flood_flag++
			if(msg)
				if((s_smileys(msg,1)) > Chan.smileys_limit) C.flood_flag++
				if(msg in C.msgs)
					if((++C.spam_num) >= Chan.spam_limit)
						C.spam_num = 0
						C.msgs.len = 0
						kick_troll(C,"No spamming!")
						return
					C.msgs = stack(C.msgs, msg, 5)
				else
					if(C.spam_num) C.spam_num--
					C.msgs = stack(C.msgs, msg, 5)
			if(C.flood_flag > Chan.flood_limit)
				C.flood_flag = 0
				C.flood_num = 0
				kick_troll(C,"No flooding!")
				return
			spawn(Chan.min_delay)
				if(C.flood_num) C.flood_num--
				if((!C.flood_num) && (C.flood_flag)) C.flood_flag--


		kick_troll(mob/chatter/C, kick_msg)
			if(!C || !C.Chan) return
			if(!kick_msg) kick_msg = "Spam guard triggered."
			Say("[C.name] has been kicked from [Chan.name].")
			if(!ChatMan.istelnet(C.key))
				// clear the chat window of everything but the output
				// to reinforce that they are really out of the program
				winset(C, "default", "menu=")
				if(C.quickbar) C.ToggleQuickBar(1)
				C << output(null, "[ckey(Chan.name)].chat.default_output")
				winset(C, "[ckey(Chan.name)].child", "right=")
				winset(C, "[ckey(Chan.name)].toggle_quickbar", "is-visible=false")
				winset(C, "[ckey(Chan.name)].set", "is-visible=false")
				winset(C, "[ckey(Chan.name)].help", "is-visible=false")
				winset(C, "[ckey(Chan.name)].default_input", "is-disabled=true")

				var/size = winget(C, "[ckey(Chan.name)].child", "size")
				var/X = copytext(size, 1, findtext(size,"x"))
				var/Y = text2num(copytext(size, findtext(size, "x")+1))+44
				winset(C, "[ckey(Chan.name)].child", "size=[X]x[Y];pos=0,0")

				C << output("You have been kicked from [Chan.name]", "[ckey(Chan.name)].chat.default_output")
				C << output("Reason: [kick_msg]", "[ckey(Chan.name)].chat.default_output")
				C << output("<font color=red>Connection closed.", "[ckey(Chan.name)].chat.default_output")

			Chan.chatters -= C
			Chan.UpdateWho()

			C.Logout() // omgwtfpwnt