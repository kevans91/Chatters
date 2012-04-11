
Operator
	proc
		ShowOps()
			set hidden = 1
			winshow(Host, "ops", 1)
			var/OpsView/OV = new()
			OV.Initialize(usr)
			OV.Display(usr, "general")
			del(OV)

		HideOps()
			set hidden = 1
			winshow(Host, "ops", 0)

		BrowseOpsGeneral()
			set hidden = 1
			var/OpsView/OV = new()
			OV.Display(usr, "general")
			del(OV)

		BrowseOpsSettings()
			set hidden = 1
			var/OpsView/OV = new()
			OV.Display(usr, "settings")
			del(OV)

		BrowseOpsRanks()
			set hidden = 1
			var/OpsView/OV = new()
			OV.Display(usr, "ranks")
			del(OV)

		BrowseOpsPrivileges()
			set hidden = 1
			var/OpsView/OV = new()
			OV.Display(usr, "privileges")
			del(OV)

		BrowseOpsActions()
			set hidden = 1
			var/OpsView/OV = new()
			OV.Display(usr, "actions")
			del(OV)

		BrowseOpsMonitor()
			set hidden = 1
			var/OpsView/OV = new()
			OV.Display(usr, "monitor")
			del(OV)

		Promote(mob/target as text|null|mob in Home.chatters - usr)
			if(!target) return
			var/mob/chatter/M = usr
			if(!M.Chan)
				alert(M, "This command is only available within a channel.", "Unable to ban chatter")
				return
			var/mob/chatter/T
			if(ismob(target))
				T = target
				target = target.name
			var/Op/Operator
			var/cKey = ckey(target)
			if(ckey(M.Chan.founder) == cKey) return
			if(cKey in M.Chan.operators)
				Operator = M.Chan.operators[cKey]
				var/r = M.Chan.op_ranks.Find(Operator.Rank)
				if(r == 1) return
				Operator.Rank = M.Chan.op_ranks[r-1]
				Operator.privileges = Operator.Rank.privs
				Operator.RankSelect.name = Operator.Rank.name
			else
				if(!M.Chan.op_ranks) return
				var/i = M.Chan.op_ranks.len
				var/OpRank/newRank = M.Chan.op_ranks[i]
				Operator = new(target, newRank)
			if(T)
				for(var/priv in Operator.privileges)
					var/OpPrivilege/P = OpMan.op_privileges[priv]
					T.verbs += text2path("/Operator/proc/[P.command]")
			if(Operator.Rank.promote)
				M.Chan.chanbot.Say("[target] was promoted to [Operator.Rank.name] by [M.name].")
			M.Chan.UpdateWho()
			ChanMan.SaveChan(Home)

		Demote(mob/target as text|null|mob in Home.chatters - usr)
			if(!target) return
			var/mob/chatter/M = usr
			if(!M.Chan)
				alert(M, "This command is only available within a channel.", "Unable to ban chatter")
				return
			var/mob/chatter/T
			if(ismob(target))
				T = target
				target = target.name
			var/cKey = ckey(target)
			if(ckey(M.Chan.founder) == cKey) return
			if(!(cKey in M.Chan.operators)) return
			var/Op/Operator = M.Chan.operators[cKey]
			var/r = M.Chan.op_ranks.Find(Operator.Rank)
			if(r == M.Chan.op_ranks.len)
				M.Chan.operators -= cKey
				M.Chan.chanbot.Say("[target] was demoted by [M.name].")
			else
				Operator.Rank = M.Chan.op_ranks[r+1]
				Operator.privileges = Operator.Rank.privs
				Operator.RankSelect.name = Operator.Rank.name
				if(Operator.Rank.demote)
					M.Chan.chanbot.Say("[target] was demoted to [Operator.Rank.name] by [M.name].")
			if(T)
				for(var/priv in Operator.privileges)
					var/OpPrivilege/P = OpMan.op_privileges[priv]
					T.verbs -= text2path("/Operator/proc/[P.command]")
			M.Chan.UpdateWho()
			ChanMan.SaveChan(Home)

		Announce(msg as text|null)
			var/mob/chatter/M = usr
			if(!M.Chan)
				alert("This command is only available within a channel.", "Unable to make announcement")
				return
			if(!msg)
				msg = input("What would you like to announce?","Enter Announcement") as message | null
				if(!msg) return

			var/announcement = {"<center><br><br><br><b>[TextMan.fadetext("#################### --- Attention! --- ####################",list("255255255","255000000","255255255"))]<br>
[TextMan.fadetext("The following is an important announcement from [M.name]: ",list("000000000","255000000","000000000"))]</b><br>
[TextMan.fadetext("----------------------------------------------------------------------------------------------------------",list("255255255","000000000","255255255"))]<br>
<pre>[msg]</pre><br>
[TextMan.fadetext("_____________________ \[end of announcement\] _____________________",list("255255255","000000000","255255255"))]
<br><br>"}
			var/no_color = {"<center><br><br><br><b>#################### --- Attention! --- ####################<br>
The following is an important announcement from [M.name]: </b><br>
----------------------------------------------------------------------------------------------------------<br>
<pre>[msg]</pre><br>
_____________________ \[end of announcement\] _____________________
<br><br>"}
			for(var/mob/chatter/C in Home.chatters)
				if(C.show_colors)
					C << output(announcement, "[ckey(Home.name)].chat.default_output")
				else
					C << output(no_color, "[ckey(Home.name)].chat.default_output")

		Mute(target as text|null|mob in Home.chatters)
			if(!target) return
			var/mob/chatter/M = usr
			var/mob/chatter/C
			if(ismob(target)) C = target
			else C = ChatMan.Get(target)
			if(!C)
				alert(M, "[target] is not currently in the channel.", "Unable to mute chatter")
				return
			target = C.name
			if(!M.Chan)
				alert(M, "This command is only available within a channel.", "Unable to mute chatter")
				return
			if(!M.Chan.mute) M.Chan.mute = new
			if(!(ckey(target) in M.Chan.mute))
				M.Chan.chanbot.Say("[target] has been muted by \[b][M.name]\[/b].")
				M.Chan.mute += ckey(target)
			else
				M.Chan.chanbot.Say("[target] is already mute.", M)
			ChanMan.SaveChan(Home)

		Voice(target as text|null|anything in Home.mute)
			if(!target) return
			var/mob/chatter/M = usr
			var/mob/chatter/C
			if(ismob(target)) C = target
			else C = ChatMan.Get(target)
			if(!C)
				alert(M, "[target] is not currently in the channel.", "Unable to voice chatter")
				return
			target = C.name
			if(!M.Chan)
				alert(M, "This command is only available within a channel.", "Unable to voice chatter")
				return
			if(!M.Chan.mute || !(ckey(target) in M.Chan.mute))
				M.Chan.chanbot.Say("[target] is already voiced.", M)
			else
				M.Chan.mute -= ckey(target)
				M.Chan.chanbot.Say("[target] has been voiced by \[b][M.name]\[/b].")
			ChanMan.SaveChan(Home)

		Kick(target as text|null|mob in Home.chatters)
			if(!target) return
			var/mob/chatter/M = usr
			if(!M.Chan)
				alert(M, "This command is only available within a channel.", "Unable to kick chatter")
				return
			var/mob/chatter/C
			if(ismob(target)) C = target
			else C = ChatMan.Get(target)
			if(!C)
				alert(M, "[target] is not currently in the channel.", "Unable to kick chatter")
				return
			var/reason = input("Please provide a reason for kicking [C.name].", "Reason") as text|null
			if(!reason) reason = "No reason supplied."
			M.Chan.chanbot.Say("[C.name] has been kicked by \[b][M.name]\[/b].")

			if(!ChatMan.istelnet(C.key))
				// clear the chat window of everything but the output
				// to reinforce that they are really out of the program
				winset(C, "default", "menu=")
				if(C.quickbar) C.ToggleQuickBar(1)
				C << output(null, "[ckey(M.Chan.name)].chat.default_output")
				winset(C, "[ckey(M.Chan.name)].child", "right=")
				winset(C, "[ckey(M.Chan.name)].toggle_quickbar", "is-visible=false")
				winset(C, "[ckey(M.Chan.name)].set", "is-visible=false")
				winset(C, "[ckey(M.Chan.name)].help", "is-visible=false")
				winset(C, "[ckey(M.Chan.name)].default_input", "is-disabled=true")

				var/size = winget(C, "[ckey(M.Chan.name)].child", "size")
				var/X = copytext(size, 1, findtext(size,"x"))
				var/Y = text2num(copytext(size, findtext(size, "x")+1))+44
				winset(C, "[ckey(M.Chan.name)].child", "size=[X]x[Y];pos=0,0")

				C << output("You have been kicked from [M.Chan.name] by [M.name]", "[ckey(M.Chan.name)].chat.default_output")
				C << output("Reason: [reason]", "[ckey(M.Chan.name)].chat.default_output")
				C << output("<font color=red>Connection closed.", "[ckey(M.Chan.name)].chat.default_output")

			M.Chan.chatters -= C
			M.Chan.UpdateWho()

			C.Logout() // omgwtfpwnt


		Ban(mob/target as text|null|mob in Home.chatters)
			if(!target) return
			var/mob/chatter/M = usr
			if(!M.Chan)
				alert(M, "This command is only available within a channel.", "Unable to ban chatter")
				return
			if(ismob(target)) target = target.name
			var/reason = input("Please provide a reason for banning [target].", "Reason") as text|null
			if(!reason) reason = "No reason supplied."
			M.Chan.chanbot.Say("[target] has been banned by \[b][M.name]\[/b].")

			if(!M.Chan.banned) M.Chan.banned = new

			M.Chan.banned += ckey(target)

			var/mob/chatter/C = ChatMan.Get(target)
			if(C)
				if(!ChatMan.istelnet(C.key))
					// clear the chat window of everything but the output
					// to reinforce that they are really out of the program
					winset(C, "default", "menu=")
					if(C.quickbar) C.ToggleQuickBar(1)
					C << output(null, "[ckey(M.Chan.name)].chat.default_output")
					winset(C, "[ckey(M.Chan.name)].child", "right=")
					winset(C, "[ckey(M.Chan.name)].toggle_quickbar", "is-visible=false")
					winset(C, "[ckey(M.Chan.name)].set", "is-visible=false")
					winset(C, "[ckey(M.Chan.name)].help", "is-visible=false")
					winset(C, "[ckey(M.Chan.name)].default_input", "is-disabled=true")

					var/size = winget(C, "[ckey(M.Chan.name)].child", "size")
					var/X = copytext(size, 1, findtext(size,"x"))
					var/Y = text2num(copytext(size, findtext(size, "x")+1))+44
					winset(C, "[ckey(M.Chan.name)].child", "size=[X]x[Y];pos=0,0")

					C << output("You have been banned from [M.Chan.name] by [M.name]", "[ckey(M.Chan.name)].chat.default_output")
					C << output("Reason: [reason]", "[ckey(M.Chan.name)].chat.default_output")
					C << output("<font color=red>Connection closed.", "[ckey(M.Chan.name)].chat.default_output")

				M.Chan.chatters -= C
				M.Chan.UpdateWho()

				C.Logout() // omgwtfpwnt
			ChanMan.SaveChan(Home)


		Unban(target as text|null|anything in Home.banned)
			var/mob/chatter/M = usr
			if(!M.Chan)
				alert(M, "This command is only available within a channel.", "Unable to unban chatter")
				return
			if(!target)
				if(M.Chan.banned && M.Chan.banned.len)
					M << output("The following chatters are banned:", "[ckey(M.Chan.name)].chat.default_output")
					for(var/B in M.Chan.banned)
						M << output(B, "[ckey(M.Chan.name)].chat.default_output")
				else
					M << output("No chatters are currently banned.", "[ckey(M.Chan.name)].chat.default_output")
				return
			if(!(ckey(target) in M.Chan.banned))
				M << output("[target] is not currently banned.", "[ckey(M.Chan.name)].chat.default_output")
				return

			M.Chan.chanbot.Say("[target] has been unbanned by \[b][M.name]\[/b].")

			M.Chan.banned -= ckey(target)
			ChanMan.SaveChan(Home)


		RoomDesc(new_desc as text|null)
			set hidden = 1
			var/mob/chatter/M = usr
			if(!M.Chan) return

			if(!new_desc)
				new_desc = input("Set [M.Chan.name]'s Room Description","[M.Chan.name]'s Room Description",M.Chan.room_desc) as message | null

			if(length(new_desc) >= 500)
				switch(alert("This description exceeds the recomended length of a room description. (500 characters) Chatters who view this description will recieve a warning asking them if they want to read this description. Submit this description anyways?","Room Description Size Alert! [length(new_desc)] characters!","Ok","No","Cancel"))
					if("Cancel") return
					if("No")
						spawn() RoomDesc()
						return
					if("Ok")
						M.Chan.room_desc_size = length(new_desc)
			else
				M.Chan.room_desc_size = length(new_desc)
			if((!new_desc) || (new_desc == "") || (trim(new_desc) == ""))
				new_desc = "An average looking room."
			M.Chan.room_desc = new_desc

OpRank
	var
		name = "ChanOP"
		desc = "Channel Operator"
		promote = "$n was promoted to $r by $u."
		demote = "$n was demoted to $r by $u."
		color = "#0000CC"
		temp = 1
		expires = 0
		elect
		elect_by
		or_higher = 1
		or_lower
		max_elect = 3
		monitor = 1
		auto_approve = 1
		pos
		list/privs
		obj/selection/select
		tmp/oplist
		tmp/oprank

	New(Pos)
		..()
		pos = Pos
		select = new(src)

	proc
		Click(mob/chatter/C)
			if(oplist)
				C << output(name, "ops_general.rank")
				C.RankSelect = src
				call(C, "HideOpRankSelect")()
			else if(oprank)
				C << output(name, "ops_general.rank")
				C.RankSelect = src
				call(C, "ShowOpRankSelect")()
			else
				C << output(name, "ops_ranks.ranks")
				C.RankSelect = src
				call(C, "UpdateOpRanks")()

		DblClick(mob/chatter/C)
			if(oplist) return
			else if(oprank) return
			else
				C << output(name, "ops_ranks.ranks")
				C.RankSelect = src
				call(C, "EditOpRank")()

OpPrivilege
	var
		name
		desc
		execute
		command
		elect
		elect_by
		or_higher
		or_lower
		margin
		min_votes
		min_delay
		monitor
		auto_approve
		obj/selection/select
		tmp/ranklist

	New()
		..()
		select = new(src)

	proc
		Click(mob/chatter/C)
			if(ranklist)
				C << output(name, "ops_ranks.privileges")
				C.PrivSelect = src
				call(C, "UpdateOpRankPrivileges")()
			else
				C << output(name, "ops_privileges.privileges")
				C.PrivSelect = src
				call(C, "ShowOpPrivilegeForm")()
				call(C, "UpdateOpPrivileges")()

		DblClick(mob/chatter/C)

OpAction

Op
	var
		name
		OpRank/Rank
		list
			actions
			privileges
		tmp/obj
			OpNameSelect/NameSelect
			OpRankSelect/RankSelect
			OpActionsSelect/ActionsSelect

	New(Name, OpRank/newRank)
		if(!Home || !Name || !newRank) return
		for(var/OpRank/R in Home.op_ranks)
			if(newRank == R)
				Rank = R
				break
		if(!Rank) return
		name = Name
		privileges = Rank.privs
		Initialize()
		..()
		Home.operators = listOpen(Home.operators)
		Home.operators[ckey(Name)] = src

	proc
		Initialize()
			NameSelect = new/obj/OpNameSelect(name, src)
			RankSelect = new/obj/OpRankSelect(Rank.name, src)
			ActionsSelect = new/obj/OpActionsSelect("[(length(actions) || "0")]", src)

Ballot
	var/voter
	var/voter_ip
	var/privilege
	var/target
	var/timestamp

	New(Voter, VoterIP, Priv, Target)
		..()
		if(!Voter || !Priv || !Target) return
		voter = Voter
		voter_ip = VoterIP
		privilege = Priv
		target = ckey(Target)
		timestamp = world.realtime

obj
	OpNameSelect
		var/Op/Op

		New(Name, Op/O)
			name = Name
			Op = O
			..()

		Click()
			Select(usr)

		proc
			Select(mob/chatter/C)
				C << output(name, "ops_name_grid.gird")
				C.NameSelect = src
				call(C, "UpdateOperators")()
				call(C, "EditOperator")()

	OpRankSelect
		var/Op/Op

		New(Rank, Op/O)
			name = Rank
			Op = O
			..()

		Click()
			Select(usr)

		proc
			Select(mob/chatter/C)
				C << output(name, "ops_name_grid.gird")
				C.NameSelect = Op.NameSelect
				call(C, "UpdateOperators")()
				call(C, "EditOperator")()

	OpActionsSelect
		var/Op/Op

		New(Actions, Op/O)
			name = Actions
			Op = O
			..()

		Click()
			Select(usr)

		proc
			Select(mob/chatter/C)
				C << output(name, "ops_name_grid.gird")
				C.NameSelect = Op.NameSelect
				call(C, "UpdateOperators")()
				call(C, "EditOperator")()