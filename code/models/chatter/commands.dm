mob
	chatter
		verb
			// Temporary, toggle name notify.
			Notify()
				name_notify = !name_notify

				src << "You will no[name_notify ? "w" : "t"] be notified if your name is said."


			Vote(ballot as text|null)
				var/OpRank/Rank = ChatMan.Rank(name)
				if(!ballot)
					usr << output("Voting Failed. usage: /Vote Privilege Name", "[ckey(Chan.name)].chat.default_output")
					usr << output("Available privileges: Promote Demote Mute Voice Kick Ban Unban", "[ckey(Chan.name)].chat.default_output")
					return
				var/space = findtext(ballot, " ")
				var/privilege = lowertext(copytext(ballot, 1, space))
				var/target
				if(space && (length(ballot) > space))
					target = copytext(ballot, space+1)
				switch(privilege)
					if("promote") votePromote(privilege, Rank, target)
					if("demote")  voteDemote (privilege, Rank, target)
					if("mute")    voteMute   (privilege, Rank, target)
					if("voice")   voteVoice  (privilege, Rank, target)
					if("kick")    voteKick   (privilege, Rank, target)
					if("ban")     voteBan    (privilege, Rank, target)
					if("unban")   voteUnban  (privilege, Rank, target)

			Send(target as text|null|mob in Home.chatters, file as file|null)
				if(telnet) return
				if(!target)
					target = input("Who would you like to send a file to?", "Send File") as text|null
					if(!target) return
				var/mob/chatter/C
				if(ismob(target)) C = target
				else C = ChatMan.Get(target)
				if(!C)
					if(src.Chan)
						src << output("[target] is not currently online.", "[ckey(src.Chan.name)].chat.default_output")
					else
						alert("[target] is not currently online.", "Unable to locate chatter")
				else
					if(ismob(C))
						var/ign = C.ignoring(ckey)
						if(ign & FILES_IGNORE)
							alert("[C.name] is currently ignoring files from you.", "Unable to Transfer File")
							return
						if(!file)
							file = input("Select the file you wish to send to [C.name]", "Upload File") as file|null
							if(!file) return
						if(length(file) > MAX_FILE_SIZE)
							alert("This file ([fsize(file)]) exceeds the limit of [fsize(MAX_FILE_SIZE)].","File Size Limit Exceeded.")
							fdel(file)
							return
					switch(alert(C, "[name] is trying to send you a file: [file] ([fsize(file)])","[name] File Transfer","Accept","Reject","Ignore"))
						if("Accept")
							C << ftp(file)
							alert("File ([file]) accepted by [C.name].","File Transfer Complete")
						if("Reject")
							alert("File ([file]) rejected by [C.name].","File Transfer Failed")
						if("Ignore")
							C.Ignore(name,"files")
							alert("File ([file]) rejected by [C.name].","File Transfer Failed")

			Set()
				if(telnet) return
				call(usr, "ShowSet")()

			Help()
				if(!telnet) ShowHelp()
				else
					src << {"//--------------------Help--------------------\\
All input is, by default, parsed into the chat. Input preceded by a backslash (/), up to the first space, will be interpreted as a command. If none is found, it shall be parsed into the chat.

Valid Commands:
<b>Login name</b> - Attempts to login as \[name\].
<b>Say message</b> - Sends message to chat.
<b>Me/My emote</b> - Emotes: "\[Name\] \[emote\]!" / "\[Name\]'s \[emote\]!"
<b>Who</b> - Displays list of current chatters.
<b>Fiter state</b> - Toggles the swearing filter. Valid states: on, off, 1, 0. All others simply toggle the filter.
<b>Ignore/Unignore chatter</b> - Ignore or stop ignoring specified chatter.
<b>Ignoring</b> - Displays list of ignored chatters.
<b>Look</b> - Displays information about the room.
\\---------------------------------------------//
"}

			Cmail()
				//ShowChattersMail()

			Say(msg as text|null)
				if(!msg) return
				if(afk) ReturnAFK()
				for(var/i=1,i<=5,i++)
					if(!client) continue
					winset(src, "[ckey(Home.name)].tag[i]", "is-checked=false")
				for(var/i=1,i<=7,i++)
					if(!client) continue
					winset(src, "[ckey(Home.name)].color[i]", "is-checked=false;text=")
					var/C = src.Colors[i]
					src.Colors[C] = null
				Chan.Say(src, msg)

			Me(msg as text|null)
				if(!msg) return
				if(afk) ReturnAFK()
				Chan.Me(src, msg)

			My(msg as text|null)
				if(!msg) return
				if(afk) ReturnAFK()
				Chan.My(src, msg)

			IM(target as text|null|mob in Home.chatters, msg as text|null)
				if(telnet) return
				if(!target)
					var/Messenger/im = new(src)
					im.Display(src)
					return
				var/mob/C
				if(ismob(target)) C = target
				else C = ChatMan.Get(target)
				for(var/i=1,i<=3,i++)
					if(!client) continue
					winset(src, "cim_[C.ckey].tag[i]", "is-checked=false")
				for(var/i=1,i<=7,i++)
					if(!client) continue
					winset(src, "cim_[C.ckey].color[i]", "is-checked=false;text=")
					var/N = src.Colors[i]
					src.Colors[N] = null
				if(!C)
					if(src.Chan)
						src << output("[target] is not currently online.", "[ckey(src.Chan.name)].chat.default_output")
					else
						alert(src, "[target] is not currently online.", "Unable to locate chatter")
				else
					if(ismob(C))
						if(!msg)
							var/Messenger/im = new(src, C.name)
							im.Display(src)
							return
						if(length(msg)>512)
							var/part2 = copytext(msg, 513)
							msg = copytext(msg, 1, 513)
							spawn(20) IM(C.name, part2)

						var/Messenger/im = new(src, C.name)
						im.Display(src)
						MsgMan.RouteMsg(src, C, msg)
					else
						if(!msg)
							var/Messenger/im = new(src, C)
							im.Display(src)
							return
						if(length(msg)>512)
							var/part2 = copytext(msg, 513)
							msg = copytext(msg, 1, 513)
							spawn(20) IM(C, part2)

						var/Messenger/im = new(src, C)
						im.Display(src)
						var/savefile/S = new()
						var/mob/chatter/M = new()

						M.name = name
						M.name_color = name_color
						M.text_color = text_color
						M.fade_name = fade_name
						M.picture = picture
						M.age = age
						M.location = location
						M.description = description
						M.interests = interests

						S["from"] << M
						S["msg"] << msg
						S["to"] << C

						src << output(src.ParseMsg(src, msg, src.say_format), "cim_[C.ckey].output")
						world.Export("[NetMan.Chatters[C]]?dest=msgman&action=msg",S)

			Ignore(mob/target as text|null|mob in Home.chatters, scope as text|null|anything in list("im", "chat", "fade", "colors", "smileys", "images", "files", "full"))
				if(!target)
					if(src.Chan)
						src << output("Please provide a name. Proper usage: /Ignore \"Chatter\" \"scope\" Available Scopes: im, chat, fade, colors, smileys, images, files, full", "[ckey(Home.name)].chat.default_output")
					else
						alert("Please provide a name. Proper usage: /Ignore \"Chatter\" \"scope\" Available Scopes: im, chat, fade, colors, smileys, images, files, full", "Ignore")
					return
				if(!ignoring) ignoring = new
				if(ismob(target)) target = target.name
				var/is_ignored = ignoring(target)
				if(is_ignored == FULL_IGNORE)
					if(src.Chan)
						src << output("You are already ignoring [target].", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are already ignoring [target].", "Unable to ignore chatter")
					return
				if(!scope) scope = "[FULL_IGNORE]"
				var/ignore_type = "this scope"
				switch(scope)
					if("im")
						scope = "[IM_IGNORE]"
						ignore_type = "instant messages"
					if("chat")
						scope = "[CHAT_IGNORE]"
						ignore_type = "chat messages"
					if("fade")
						scope = "[FADE_IGNORE]"
						ignore_type = "fades"
					if("colors")
						scope = "[COLOR_IGNORE]"
						ignore_type = "colors"
					if("smileys")
						scope = "[SMILEY_IGNORE]"
						ignore_type = "smileys"
					if("images")
						scope = "[IMAGES_IGNORE]"
						ignore_type = "images"
					if("files")
						scope = "[FILES_IGNORE]"
						ignore_type = "files"
					if("full")		scope = "[FULL_IGNORE]"
				var/num = text2num(scope)
				if(num && isnum(num))
					if(num & is_ignored)
						if(src.Chan)
							src << output("You are already ignoring [ignore_type] from [target].", "[ckey(Home.name)].chat.default_output")
						else
							alert("You are already ignoring [ignore_type] from [target].","Unable to ignore chatter")
						return
					num += is_ignored
					ignore_type = ""
					if(num == 31) num = FULL_IGNORE
					if(num & FULL_IGNORE) scope = FULL_IGNORE
					else
						scope = 0
						if(num & IM_IGNORE)
							scope |= IM_IGNORE
							ignore_type += "\n	- instant messages"
							if(ckey(target) in msgHandlers)
								winset(src, "cim_[ckey(target)]", "is-visible=false")
						if(num & CHAT_IGNORE)
							scope |= CHAT_IGNORE
							ignore_type += "\n	- chat messages"
						if(num & FADE_IGNORE)
							scope |= FADE_IGNORE
							ignore_type += "\n	- fade name"
						if(num & COLOR_IGNORE)
							scope |= COLOR_IGNORE
							ignore_type += "\n	- colors"
						if(num & SMILEY_IGNORE)
							scope |= SMILEY_IGNORE
							ignore_type += "\n	- smileys"
						if(num & IMAGES_IGNORE)
							scope |= IMAGES_IGNORE
							ignore_type += "\n	- images"
						if(num & FILES_IGNORE)
							scope |= FILES_IGNORE
							ignore_type += "\n	- files"
						if(!scope)
							if(src.Chan)
								src << output("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files, full", "[ckey(Home.name)].chat.default_output")
							else
								alert("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files full","Unable to ignore chatter")
							return
				else
					if(src.Chan)
						src << output("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files full", "[ckey(Home.name)].chat.default_output")
					else
						alert("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files full","Unable to ignore chatter")
					return
				if(!is_ignored) ignoring += ckey(target)
				ignoring[ckey(target)] = scope
				if(length(ignore_type))
					if(src.Chan)
						src << output("You are now ignoring the following from [target]: [ignore_type]", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are now ignoring the following from [target]: [ignore_type]", "Ignoring chatter")
				else
					if(src.Chan)
						src << output("You are now fully ignoring [target].", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are now fully ignoring [target].", "Ignoring chatter")
				ChatMan.Save(src)


			Unignore(mob/target as text|null|anything in ignoring, scope as text|null|anything in list("im", "chat", "fade", "colors", "smileys", "images", "files", "full"))
				if(!target)
					if(src.Chan)
						src << output("Please provide a name. Proper usage: /Unignore \"Chatter\" \"scope\" Available Scopes: im, chat, fade, colors, smileys, images, files, full", "[ckey(Home.name)].chat.default_output")
					else
						alert("Please provide a name. Proper usage: /Unignore \"Chatter\" \"scope\" Available Scopes: im, chat, fade, colors, smileys, images, files, full", "Unignore")
					return
				if(!ignoring || !ignoring.len)
					if(src.Chan)
						src << output("You are not currently ignoring any chatters.", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are not currently ignoring any chatters.", "Unable to unignore chatter")
					return
				if(ismob(target)) target = target.name
				var/ign = ignoring(target)
				if(!ign)
					if(src.Chan)
						src << output("You are not currently ignoring [target]", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are not currently ignoring [target]", "Unable to unignore chatter")
					return
				if(!scope) scope = "[FULL_IGNORE]"
				var/ignore_type = "this scope"
				switch(scope)
					if("im")
						scope = "[IM_IGNORE]"
						ignore_type = "instant messages"
					if("chat")
						scope = "[CHAT_IGNORE]"
						ignore_type = "chat messages"
					if("fade")
						scope = "[FADE_IGNORE]"
						ignore_type = "fades"
					if("colors")
						scope = "[COLOR_IGNORE]"
						ignore_type = "colors"
					if("smileys")
						scope = "[SMILEY_IGNORE]"
						ignore_type = "smileys"
					if("images")
						scope = "[IMAGES_IGNORE]"
						ignore_type = "images"
					if("files")
						scope = "[FILES_IGNORE]"
						ignore_type = "files"
					if("full")		scope = "[FULL_IGNORE]"
				var/num = text2num(scope)
				if(num && isnum(num))
					if((num != FULL_IGNORE) && !(num & ign))
						if(src.Chan)
							src << output("You are not currently ignoring [ignore_type] from [target].", "[ckey(Home.name)].chat.default_output")
						else
							alert("You are not currently ignoring [ignore_type] from [target].","Unable to unignore chatter")
						return
					ignore_type = ""
					if(num == 31) num = FULL_IGNORE
					if(num & FULL_IGNORE) scope = FULL_IGNORE
					else
						scope = 0
						if(num & IM_IGNORE)
							scope |= IM_IGNORE
							if(ign - IM_IGNORE)
								ignore_type += "\n	- instant messages"
						if(num & CHAT_IGNORE)
							scope |= CHAT_IGNORE
							if(ign - CHAT_IGNORE)
								ignore_type += "\n	- chat messages"
						if(num & FADE_IGNORE)
							scope |= FADE_IGNORE
							if(ign - FADE_IGNORE)
								ignore_type += "\n	- fade name"
						if(num & COLOR_IGNORE)
							scope |= COLOR_IGNORE
							if(ign - COLOR_IGNORE)
								ignore_type += "\n	- colors"
						if(num & SMILEY_IGNORE)
							scope |= SMILEY_IGNORE
							if(ign - SMILEY_IGNORE)
								ignore_type += "\n	- smileys"
						if(num & IMAGES_IGNORE)
							scope |= IMAGES_IGNORE
							if(ign - IMAGES_IGNORE)
								ignore_type += "\n	- images"
						if(num & FILES_IGNORE)
							scope |= FILES_IGNORE
							if(ign - FILES_IGNORE)
								ignore_type += "\n	- files"
						if(!scope)
							if(src.Chan)
								src << output("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files, full", "[ckey(Home.name)].chat.default_output")
							else
								alert("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files, full","Unable to unignore chatter")
							return
				else
					if(src.Chan)
						src << output("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files, full", "[ckey(Home.name)].chat.default_output")
					else
						alert("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files, full","Unable to unignore chatter")
					return
				if(scope == FULL_IGNORE) ignoring -= ckey(target)
				else ignoring[ckey(target)] &= ~scope
				if(!ignoring[ckey(target)])
					ignoring -= ckey(target)
					ignore_type = ""
				if(length(ignore_type))
					if(src.Chan)
						src << output("You are no longer ignoring the following from [target]: [ignore_type]", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are no longer ignoring the following from [target]: [ignore_type]", "Unignoring chatter")
				else
					if(src.Chan)
						src << output("You are no longer ignoring [target].", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are no longer ignoring [target].", "Unignoring chatter")
				ChatMan.Save(src)

			Ignoring(mob/target as text|null|anything in ignoring)
				if(!ignoring || !ignoring.len)
					if(src.Chan)
						src << output("You are not currently ignoring any chatters.", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are not currently ignoring any chatters.", "No chatters ignored")
					return
				if(!target)
					var/ignored
					for(var/i in ignoring)
						var/scoped
						if((ignoring[i] & FULL_IGNORE)) scoped = "Full ignore"
						else
							if((ignoring[i] & IM_IGNORE))
								if(!scoped) scoped = "IMs"
								else scoped += ", IMs"
							if((ignoring[i] & CHAT_IGNORE))
								if(!scoped) scoped = "chat"
								else scoped += ", chat"
							if((ignoring[i] & FADE_IGNORE))
								if(!scoped) scoped = "fade name"
								else scoped += ", fade name"
							if((ignoring[i] & COLOR_IGNORE))
								if(!scoped) scoped = "colors"
								else scoped += ", colors"
							if((ignoring[i] & SMILEY_IGNORE))
								if(!scoped) scoped = "smileys"
								else scoped += ", smileys"
							if((ignoring[i] & IMAGES_IGNORE))
								if(!scoped) scoped = "images"
								else scoped += ", images"
							if((ignoring[i] & FILES_IGNORE))
								if(!scoped) scoped = "files"
								else scoped += ", files"
						ignored += "\n[i] - [scoped]"
					if(src.Chan)
						src << output("You are currently ignoring the following chatters.[ignored]", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are currently ignoring the following chatters.[ignored]", "Not Ignoring chatter")
					return
				if(ismob(target)) target = target.name
				var/ign = ignoring(target)
				if(!ign)
					if(src.Chan)
						src << output("You are not currently ignoring [target]", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are not currently ignoring [target]", "Not Ignoring chatter")
					return
				var/ignore_type = ""
				if(!(ign & FULL_IGNORE))
					if(ign & IM_IGNORE)
						if(ign - IM_IGNORE)
							ignore_type += "\n	- instant messages"
					if(ign & CHAT_IGNORE)
						if(ign - CHAT_IGNORE)
							ignore_type += "\n	- chat messages"
					if(ign & FADE_IGNORE)
						if(ign - FADE_IGNORE)
							ignore_type += "\n	- fade name"
					if(ign & COLOR_IGNORE)
						if(ign - COLOR_IGNORE)
							ignore_type += "\n	- colors"
					if(ign & SMILEY_IGNORE)
						if(ign - SMILEY_IGNORE)
							ignore_type += "\n	- smileys"
					if(ign & IMAGES_IGNORE)
						if(ign - IMAGES_IGNORE)
							ignore_type += "\n	- images"
					if(ign & FILES_IGNORE)
						if(ign - FILES_IGNORE)
							ignore_type += "\n	- files"
				if(length(ignore_type))
					if(src.Chan)
						src << output("You are ignoring the following from [target]: [ignore_type]", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are ignoring the following from [target]: [ignore_type]", "Ignoring chatter")
				else
					if(src.Chan)
						src << output("You are fully ignoring [target].", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are fully ignoring [target].", "Ignoring chatter")

			Look()
				if(!Chan) return
				if(!Chan.room_desc)
					src << output("Looking around, you see....\n\tAn average looking room.", "[ckey(Chan.name)].chat.default_output")
					return
				if(Chan.room_desc_size >= 500)
					switch(alert("This room description exceeds the recomended room description size. (500 characters) Would you like to view it anyways?","Room Description Size Alert! [Chan.room_desc_size] characters!","Yes","No"))
						if("No") return
				src << output("Looking around, you see....\n\t[Chan.room_desc]", "[ckey(Chan.name)].chat.default_output")


			LookAt(t as text|null|mob in Home.chatters)
				if(!t || telnet) return
				var/mob/chatter/C
				if(ismob(t)) C = t
				else C = ChatMan.Get(t)
				if(!C)
					if(src.Chan)
						src << output("[t] is not currently online.", "[ckey(src.Chan.name)].chat.default_output")
					else
						alert(src, "[t] is not currently online.", "Unable to locate chatter")
				else
					src << output(null, "profile.output")
					if(C.picture)
						src << output("<img src='[C.picture]' width=64 height=64>\...", "profile.output")
					else
						src << browse_rsc('./resources/images/noimage.png', "noimage.png")
						src << output("<img src='noimage.png' width=64 height=64>\...", "profile.output")
					winset(src, "profile.key", "text=' [TextMan.escapeQuotes(C.name)]")
					winset(src, "profile.age", "text=' [TextMan.escapeQuotes(C.age)]")
					winset(src, "profile.gender", "text=' [C.gender]")
					winset(src, "profile.location", "text=' [TextMan.escapeQuotes(C.location)]")
					winset(src, "profile.description", "text=' [TextMan.escapeQuotes(C.description)]")
					winset(src, "profile.interests", "text=' [TextMan.escapeQuotes(C.interests)]")
					winset(src, "profile", "is-visible=true")
					winset(src, "profile.show_button", "command='ShowCode \"[C.name]\"';")
					winset(src, "profile.im_button", "command='IM \"[C.name]\"';")

			ShowCode(t as text|null|mob in Home.chatters)
				if(telnet) return
				if(afk) ReturnAFK()
				var/showcode_snippet/S = new
				if(t)
					var/mob/chatter/C
					if(ismob(t)) C = t
					else C = ChatMan.Get(t)
					if(!C)
						if(src.Chan)
							src << output("[t] is not currently online.", "[ckey(src.Chan.name)].chat.default_output")
						else
							alert(src, "[t] is not currently online.", "Unable to locate chatter")
					else
						var/ign = C.ignoring(src)
						if(ign && CHAT_IGNORE)
							src << "<b>Unable to show code!</b>"
							src << "[C.name] is ignoring you."
							return
					S.target = C.ckey
				else
					if(!src.Chan || Chan.ismute(src))
						if(src.Chan) src.Chan.chanbot.Say("I'm sorry, but you appear to be muted.", src)
						return

				var/iCode = input("Paste your code below") as message
				S.owner = "[src.name]"
				S.code = iCode
				S.Send(1)

			ShowText(t as text|null|mob in Home.chatters)
				if(telnet) return
				if(afk) ReturnAFK()
				var/showcode_snippet/S = new
				if(t)
					var/mob/chatter/C
					if(ismob(t)) C = t
					else C = ChatMan.Get(t)
					if(!C)
						if(src.Chan)
							src << output("[t] is not currently online.", "[ckey(src.Chan.name)].chat.default_output")
						else
							alert(src, "[t] is not currently online.", "Unable to locate chatter")
					else
						var/ign = C.ignoring(src)
						if(ign && CHAT_IGNORE)
							src << "<b>Unable to show code!</b>"
							src << "[C.name] is ignoring you."
							return
					S.target = C.ckey
				else
					if(!src.Chan || Chan.ismute(src))
						if(src.Chan) src.Chan.chanbot.Say("I'm sorry, but you appear to be muted.", src)
						return

				var/iCode = input("Paste your text below") as message
				S.owner = "[src.name]"
				S.code = iCode
				S.Send()

			afk(msg as text|null)
				if(!Chan || telnet) return
				if(!afk)
					if(!msg) msg = auto_reason
					Home.GoAFK(src, msg)
				else
					ReturnAFK()
			Filter(msg as text|null)
				switch(ckey(msg))
					if("on","1") filter=2
					if("off","0") filter=0
					else filter=(!filter && 2)
				src << "Filter is now [filter ? "on" : "off"]."

			who()
				set hidden = 1
				if(!telnet) return
				var chatter_array[] = list()
				for(var/mob/chatter/C in Home.chatters)
					chatter_array += "[C.name][C.afk ? "\[AFK\]" : ""]"
				src << "<b>Chatters:</b> [dd_list2text(chatter_array, ", ")]"

			login(telnet_key as text|null)
				set hidden = 1
				if(!telnet_key || !telnet) return
				for(var/mob/chatter/C in Home.chatters)
					if((C.key && C.key==telnet_key) || C.name==telnet_key)
						src << "<b>Error:</b> That key is already logged in!"
						return
				var/savefile/S = new("./data/saves/tel.net")
				if(!S || !length(S))
					src << "<b>Error:</b> There is no password saved for that key!"
					return
				var/list/L = new
				S["telnet"] >> L
				if(!L || !L.len)
					src << "<b>Error:</b> There is no password saved for that key!"
					return
				var/key_hash = md5(telnet_key)
				if(key_hash in L)
					var/telnet_pass = input("Please enter your telnet password:", "Telnet Key Login") as password|null
					if(!telnet_pass)
						del(L)
						return
					if(L[key_hash] != md5(telnet_pass))
						src << "<b>Error:</b> Incorrect password!"
						del(L)
						return
					del(L)
					src << "You have successfully logged in as <b>telnet_key</b>!"
					name = telnet_key
					fade_name = name
					Home.UpdateWho()
				else src << "<b>Error:</b> There is no password saved for that key!"
