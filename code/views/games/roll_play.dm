
Games
	RollPlay
		proc
			RollPlay(t as text|null)
				if(!t) return
				var/mob/chatter/M = usr
				if(!M) return
				var/msg_len = length(t)
				if(msg_len > 1)
					var/first_char = copytext(t, 1, 2)
					if(first_char == "/")
						var/space = findtext(t, " ")
						if(!space) space = msg_len
						var/command = lowertext(copytext(t, 2, space))
						switch(command)
							if("me")
								if(msg_len > space+1)
									var/msg = copytext(t, space+1)
									call(M, "RollMe")(msg)
							if("my")
								if(msg_len > space+1)
									var/msg = copytext(t, space+1)
									call(M, "RollMy")(msg)
							if("roll")
								var/msg
								if(msg_len > space+1)
									msg = copytext(t, space+1)
								call(M,"Roll")(msg)
							else
								if(msg_len > space+1)
									var/msg = copytext(t, space+1)
									for(var/v in M.verbs)
										if(lowertext(v:name) == lowertext(command))
											call(M, "[v:name]")(arglist(explode(msg, " ")))
											break
					else
						call(M, "RollSay")(t)