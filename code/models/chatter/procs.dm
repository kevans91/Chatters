
mob
	chatter
		proc
			ReturnAFK()
				Home.ReturnAFK(src)


			Ticker()
				if(!src.client) return
				if(winget(src, "style", "is-visible") == "true")
					src << output(TextMan.strip_html(ParseTime(ticker)), "style.time")
					ticker ^= 1
				spawn(5) Ticker()


			votePromote(privilege, OpRank/Rank, target)
				var/OpPrivilege/P = OpMan.op_privileges["Promote"]
				if(!canVote(P, target)) return
				var/OpRank/TargetRank = ChatMan.Rank(target)
				if(TargetRank == "All") TargetRank = Chan.op_ranks[Chan.op_ranks.len]
				else if(TargetRank.pos == 1)
					usr << output("Voting Failed. This chatter can not be promoted any higher.", "[ckey(Chan.name)].chat.default_output")
					return
				else TargetRank = Chan.op_ranks[TargetRank.pos-1]
				if(!canElect(Rank, TargetRank)) return
				if(TargetRank.max_elect)
					var/i=0
					for(var/op in Chan.operators)
						var/Op/O = Chan.operators[op]
						if(O.Rank == TargetRank) i++
					if(i >= TargetRank.max_elect)
						if(!TargetRank.temp)
							usr << output("Voting Failed. The maximum number of target rank operators has been reached.", "[ckey(Chan.name)].chat.default_output")
							return
				castVote(P, target, TargetRank)


			voteDemote(privilege, OpRank/Rank, target)
				var/OpPrivilege/P = OpMan.op_privileges["Demote"]
				if(!canVote(P, target)) return
				var/OpRank/TargetRank = ChatMan.Rank(target)
				if(TargetRank == "All")
					usr << output("Voting Failed. This chatter can not be demoted any further.", "[ckey(Chan.name)].chat.default_output")
					return
				if(!canElect(Rank, TargetRank)) return
				castVote(P, target)


			voteMute(privilege, OpRank/Rank, target)
				var/OpPrivilege/P = OpMan.op_privileges["Mute"]
				if(!canVote(P, target)) return
				var/OpRank/TargetRank = ChatMan.Rank(target)
				if(!isAuthorized(P, Rank, TargetRank)) return
				castVote(P, target)


			voteVoice(privilege, OpRank/Rank, target)
				var/OpPrivilege/P = OpMan.op_privileges["Voice"]
				if(!canVote(P, target)) return
				var/OpRank/TargetRank = ChatMan.Rank(target)
				if(!isAuthorized(P, Rank, TargetRank)) return
				if(!(ckey(target) in Chan.mute))
					usr << output("Voting Failed. This chatter is not currently muted.", "[ckey(Chan.name)].chat.default_output")
					return
				castVote(P, target)


			voteKick(privilege, OpRank/Rank, target)
				var/OpPrivilege/P = OpMan.op_privileges["Kick"]
				if(!canVote(P, target)) return
				var/OpRank/TargetRank = ChatMan.Rank(target)
				if(!isAuthorized(P, Rank, TargetRank)) return
				var/mob/chatter/T = ChatMan.Get(target)
				if(!ismob(T) || !(T in Chan.chatters))
					usr << output("Voting Failed. Unable to locate [target].", "[ckey(Chan.name)].chat.default_output")
					return
				castVote(P, target)


			voteBan(privilege, OpRank/Rank, target)
				var/OpPrivilege/P = OpMan.op_privileges["Ban"]
				if(!canVote(P, target)) return
				var/OpRank/TargetRank = ChatMan.Rank(target)
				if(!isAuthorized(P, Rank, TargetRank)) return
				castVote(P, target)


			voteUnban(privilege, OpRank/Rank, target)
				var/OpPrivilege/P = OpMan.op_privileges["Unban"]
				if(!canVote(P, target)) return
				var/OpRank/TargetRank = ChatMan.Rank(target)
				if(!isAuthorized(P, Rank, TargetRank)) return
				if(!(ckey(target) in Chan.banned))
					usr << output("Voting Failed. This chatter is not currently banned.", "[ckey(Chan.name)].chat.default_output")
					return
				castVote(P, target)


			canVote(OpPrivilege/Priv, target)
				if(!Priv)
					usr << output("Voting Failed. Unknown privilege: [Priv.name]", "[ckey(Chan.name)].chat.default_output")
					return FALSE
				if(!Priv.elect)
					usr << output("Voting Failed. Voting is disabled for [Priv.name].", "[ckey(Chan.name)].chat.default_output")
					return FALSE
				if(!target)
					usr << output("Voting Failed. No target name provided. Usage: /Vote [Priv.command] Name", "[ckey(Chan.name)].chat.default_output")
					return FALSE
				return TRUE


			hasVoted(OpPrivilege/Priv)
				if(!Priv) return
				for(var/Ballot/b in Chan.ballots)
					if((b.voter_ip == client.address) && (b.privilege == Priv.name))
						usr << output("Voting Failed. You may only cast one ballot for this privilege.", "[ckey(Chan.name)].chat.default_output")
						return TRUE
				return FALSE


			canElect(OpRank/Rank, OpRank/TargetRank)
				if(!Rank || !TargetRank) return
				if(!TargetRank.elect)
					usr << output("Voting Failed. The target rank does not allow elections.", "[ckey(Chan.name)].chat.default_output")
					return FALSE
				if(Rank == "All")
					if(TargetRank.elect_by != Rank)
						if(!TargetRank.or_lower)
							usr << output("Voting Failed. You are not authorized to vote on the target rank.", "[ckey(Chan.name)].chat.default_output")
							return FALSE
				else
					var/OpRank/ByRank
					if(TargetRank.elect_by == "All")
						if(!TargetRank.or_higher) return FALSE
					else
						for(var/OpRank/R in Chan.op_ranks)
							if(R.name == TargetRank.elect_by)
								ByRank = R
								break
						if(Rank.pos < ByRank.pos)
							if(!TargetRank.or_lower)
								usr << output("Voting Failed. You are not authorized to vote on the target rank.", "[ckey(Chan.name)].chat.default_output")
								return FALSE
						else if(Rank.pos > ByRank.pos)
							if(!TargetRank.or_higher)
								usr << output("Voting Failed. You are not authorized to vote on the target rank.", "[ckey(Chan.name)].chat.default_output")
								return FALSE
				return TRUE


			isAuthorized(OpPrivilege/P, OpRank/Rank, OpRank/TargetRank)
				if(!P.elect)
					usr << output("Voting Failed. This privilege does not allow elections.", "[ckey(Chan.name)].chat.default_output")
					return FALSE
				if(Rank == "All")
					if((P.elect_by != Rank) && (!P.or_lower))
						usr << output("Voting Failed. You are not authorized to vote [P.command].", "[ckey(Chan.name)].chat.default_output")
						return FALSE
				else
					var/OpRank/ByRank
					if((P.elect_by == "All") && (!P.or_higher))
						usr << output("Voting Failed. You are not authorized to vote [P.command].", "[ckey(Chan.name)].chat.default_output")
						return FALSE
					else
						for(var/OpRank/R in Chan.op_ranks)
							if(R.name == P.elect_by)
								ByRank = R
								break
						if(ByRank)
							if((Rank.pos < ByRank.pos) && (!P.or_lower))
								usr << output("Voting Failed. You are not authorized to vote [P.command].", "[ckey(Chan.name)].chat.default_output")
								return FALSE
							else if((Rank.pos > ByRank.pos) && (!P.or_higher))
								usr << output("Voting Failed. You are not authorized to vote [P.command].", "[ckey(Chan.name)].chat.default_output")
								return FALSE
						else if(!P.or_lower || P.or_higher)
							usr << output("Voting Failed. You are not authorized to vote [P.command].", "[ckey(Chan.name)].chat.default_output")
							return FALSE
				if((Rank == "All") && TargetRank != Rank)
					usr << output("Voting Failed. You are not authorized to vote [P.name] this chatter.", "[ckey(Chan.name)].chat.default_output")
					return FALSE
				if((TargetRank != "All") && (Rank.pos <= TargetRank.pos))
					usr << output("Voting Failed. You are not authorized to vote [P.name] this chatter.", "[ckey(Chan.name)].chat.default_output")
					return FALSE
				return TRUE


			castVote(OpPrivilege/P, target, TargetRank)
				Chan.ballots = listOpen(Chan.ballots)
				if(hasVoted(P)) return
				Chan.ballots += new/Ballot(name, client.address, P.name, target)
				usr << output("Vote cast successfully.", "[ckey(Chan.name)].chat.default_output")
				Chan.TallyVotes(P, TargetRank)


			ParseMsg(mob/chatter/M, msg, msg_format[], emote, rp)
				if(!M || !msg || !msg_format || !msg_format.len) return

				var/parsed_msg = ""
				var/ign = ignoring(M)
				msg = trim(msg)
				var/rp_start = findtext(msg, ":")
				if(rp_start == 1)
					var/rp_end = findtext(msg, ":", 2)
					if(rp_end)
						var/RP = copytext(msg, 2, rp_end)
						msg = copytext(msg, rp_end+1)
						return ParseMsg(M, msg, src.rpsay_format, 0, RP)

				var/punctuation
				var/msg_punctuation = copytext(msg, length(msg))
				switch(msg_punctuation)
					if(".")
						punctuation = "."
						if(forced_punctuation)
							if(copytext(msg, length(msg)) == ".")
								if((msg_format.Find("said") > msg_format.Find("$msg")) || (msg_format.Find("says") > msg_format.Find("$msg")))
									msg = copytext(msg, 1, length(msg))+","
					if("!") punctuation = "!"
					if("?") punctuation = "?"
					else
						punctuation = "."
						if(forced_punctuation)
							if((msg_format.Find("said") > msg_format.Find("$msg")) || (msg_format.Find("says") > msg_format.Find("$msg")))
								msg += ","
							else msg += "."

				for(var/s in msg_format)
					if(s == "$name")
						if((ign & COLOR_IGNORE) || !show_colors)
							if(emote == 2)
								var/end = "'s"
								if(copytext(M.name, length(M.name)-1) == "s")
									end = "'"
								parsed_msg += M.name+end
							else
								parsed_msg += M.name
						else if((ign & FADE_IGNORE) || emote || rp)
							if(emote == 2)
								var/end = "'s"
								if(copytext(M.name, length(M.name)-1) == "s")
									end = "'"
								if(M.name_color)
									parsed_msg += "<font color=[M.name_color]>[M.name][end]</font>"
								else
									parsed_msg += "[M.name][end]"
							else
								if(M.name_color)
									parsed_msg += "<font color=[M.name_color]>[M.name]</font>"
								else
									parsed_msg += M.name
						else
							if(M.fade_name != M.name)
								parsed_msg += M.fade_name
							else if(M.name_color)
								parsed_msg += "<font color=[M.name_color]>[M.name]</font>"
							else
								parsed_msg += M.name
					else if(s == "$rp")
						if((ign & COLOR_IGNORE) || !show_colors)
							parsed_msg += rp
						else
							if(M.name_color)
								parsed_msg += "<font color=[M.name_color]>[rp]</font>"
							else
								parsed_msg += rp
					else if(s == "$msg")
						if(name_notify)
							// Highlight your name!
							msg = dd_replaceText(msg, name, "<font color='red'>[name]</font>")

						if((ign & COLOR_IGNORE) || !show_colors)
							parsed_msg += msg
						else if(!emote)
							if(M.text_color)
								parsed_msg += "<font color=[M.text_color]>[msg]</font>"
							else
								parsed_msg += msg
						else
							if(M.name_color)
								parsed_msg += "<font color=[M.name_color]>[msg]</font>"
							else
								parsed_msg += msg
					else if(s == "$ts")
						parsed_msg += ParseTime()
					else if(s == "says")
						switch(punctuation)
							if(".") parsed_msg += s
							if("!") parsed_msg += "exclaims"
							if("?") parsed_msg += "asks"
					else if(s == "said")
						switch(punctuation)
							if(".") parsed_msg += s
							if("!") parsed_msg += "exclaimed"
							if("?") parsed_msg += "asked"
					else parsed_msg += s

				return parsed_msg


			ParseTime(hide_ticker)
				var/timestamp = world.timeofday + src.time_offset * 36000
				var/c = hide_ticker ? " " : ":"
				
				if (_24hr_time)
					return time2text(timestamp, "<b>\[</b>hh[c]mm[c]ss<b>\]</b>")
				
				var/hour = text2num(time2text(timestamp, "hh"))
				var/ampm = (hour > 11) ? "pm" : "am"
				hour = (hour % 12) || 12
				if (hour < 10)
					hour = "0[hour]"
				
				return time2text(timestamp, "<b>\[</b>[hour][c]mm[c]ss [ampm]<b>\]</b>")


			ignoring(mob/M)
				if(ignoring && ignoring.len)
					if(istext(M))
						if(ckey(M) in ignoring)
							var/ign = ignoring[ckey(M)]
							if(ign == FULL_IGNORE) return FULL_IGNORE-1
							else return ign
					if(ismob(M))
						if(ckey(M.name) in ignoring)
							var/ign = ignoring[ckey(M.name)]
							if(ign == FULL_IGNORE) return FULL_IGNORE-1
							else return ign


			fsize(F)
				var/l=length(F);if(isnum(F))l=F
				if(l<1024)return"[round(l,0.01)]B"; l/=1024
				if(l<1024)return"[round(l,0.01)]KB";l/=1024
				if(l<1024)return"[round(l,0.01)]MB";l/=1024
				.="[l]GB"