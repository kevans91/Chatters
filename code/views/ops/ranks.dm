Operators
	Ranks

		proc
			UpdateOperatorRanks()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				if(C.RankSelect)
					C.RankSelect.name = winget(C, "ops_ranks.name", "text")
					C.RankSelect.select.name = C.RankSelect.name
					C.RankSelect.desc = winget(C, "ops_ranks.description", "text")
					C.RankSelect.promote = winget(C, "ops_ranks.promote", "text='[escapeQuotes()]'")
					C.RankSelect.demote = winget(C, "ops_ranks.demote", "text='[escapeQuotes()]'")
					C.RankSelect.color = winget(C, "ops_ranks.color", "text='[escapeQuotes()]'")
					C.RankSelect.temp = (winget(C, "ops_ranks.temporary", "is-checked")=="true")? 1 : 0
					C.RankSelect.expires = text2num(winget(C, "ops_ranks.expires", "text"))
					C.RankSelect.elect = (winget(C, "ops_ranks.electable", "is-checked")=="true")? 1 : 0
					C.RankSelect.elect_by = winget(C, "ops_ranks.electable_by", "text")
					C.RankSelect.or_higher = (winget(C, "ops_ranks.or_higher", "is-checked")=="true")? 1 : 0
					C.RankSelect.or_lower = (winget(C, "ops_ranks.or_lower", "is-checked")=="true")? 1 : 0
					C.RankSelect.max_elect = text2num(winget(C, "ops_ranks.max_electable", "text"))
					C.RankSelect.monitor = (winget(C, "ops_ranks.monitor", "is-checked")=="true")? 1 : 0
					C.RankSelect.auto_approve = (winget(C, "ops_ranks.auto_approve", "is-checked")=="true")? 1 : 0
					call(C, "UpdateOpRanks")()
				for(var/OpRank/Rank in OpMan.op_ranks)
					OpMan.SaveRankXML(Rank)
				winset(C, "ops_ranks.updated", "is-visible=true")
				sleep(50)
				if(C && C.client)
					winset(C, "ops_ranks.updated", "is-visible=false")

			NewOpRank()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				C.RankSelect = new(OpMan.op_ranks.len+1)
				var/unique, num
				while(!unique)
					unique=null
					for(var/OpRank/R in OpMan.op_ranks)
						if(R.name == C.RankSelect.name+"[num]")
							unique = 0
							if(!num) num=1
							else num++
					if(isnull(unique))
						unique = TRUE
						if(!isnull(num))
							C.RankSelect.name = C.RankSelect.name+"[num]"
							C.RankSelect.select.name = C.RankSelect.name
				OpMan.op_ranks += C.RankSelect
				call(C,"UpdateOpRanks")()
				call(C,"ShowOpRankForm")()

			EditOpRank()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				if(!C.RankSelect) return
				call(C,"UpdateOpRanks")()
				call(C,"ShowOpRankForm")()

			ShowOpRankForm()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				winset(C, "ops_ranks.info_left", "is-visible=false")
				winset(C, "ops_ranks.info", "is-visible=false")
				winset(C, "ops_ranks.info_right", "is-visible=false")

				winset(C, "ops_ranks.name_label", "is-visible=true")
				winset(C, "ops_ranks.name", "is-visible=true")
				winset(C, "ops_ranks.description_label", "is-visible=true")
				winset(C, "ops_ranks.description", "is-visible=true")
				winset(C, "ops_ranks.promote_label", "is-visible=true")
				winset(C, "ops_ranks.promote", "is-visible=true")
				winset(C, "ops_ranks.demote_label", "is-visible=true")
				winset(C, "ops_ranks.demote", "is-visible=true")
				winset(C, "ops_ranks.color_label", "is-visible=true")
				winset(C, "ops_ranks.color_button", "is-visible=true")
				winset(C, "ops_ranks.color", "is-visible=true")
				winset(C, "ops_ranks.temporary", "is-visible=true")
				winset(C, "ops_ranks.expires_label", "is-visible=true")
				winset(C, "ops_ranks.expires", "is-visible=true")
				winset(C, "ops_ranks.days_label", "is-visible=true")
				winset(C, "ops_ranks.electable", "is-visible=true")
				winset(C, "ops_ranks.electable_by", "is-visible=true")
				winset(C, "ops_ranks.or_higher", "is-visible=true")
				winset(C, "ops_ranks.or_lower", "is-visible=true")
				winset(C, "ops_ranks.max_elect_label", "is-visible=true")
				winset(C, "ops_ranks.max_electable", "is-visible=true")
				winset(C, "ops_ranks.monitor", "is-visible=true")
				winset(C, "ops_ranks.auto_approve", "is-visible=true")
				winset(C, "ops_ranks.privileges_label", "is-visible=true")
				winset(C, "ops_ranks.privileges", "is-visible=true")
				winset(C, "ops_ranks.add_priv_button", "is-visible=true")
				winset(C, "ops_ranks.remove_priv_button", "is-visible=true")

			HideOpRankForm()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				winset(C, "ops_ranks.info_left", "is-visible=true")
				winset(C, "ops_ranks.info", "is-visible=true")
				winset(C, "ops_ranks.info_right", "is-visible=true")

				winset(C, "ops_ranks.name_label", "is-visible=false")
				winset(C, "ops_ranks.name", "is-visible=false")
				winset(C, "ops_ranks.description_label", "is-visible=false")
				winset(C, "ops_ranks.description", "is-visible=false")
				winset(C, "ops_ranks.promote_label", "is-visible=false")
				winset(C, "ops_ranks.promote", "is-visible=false")
				winset(C, "ops_ranks.demote_label", "is-visible=false")
				winset(C, "ops_ranks.demote", "is-visible=false")
				winset(C, "ops_ranks.color_label", "is-visible=false")
				winset(C, "ops_ranks.color_button", "is-visible=false")
				winset(C, "ops_ranks.color", "is-visible=false")
				winset(C, "ops_ranks.temporary", "is-visible=false")
				winset(C, "ops_ranks.expires_label", "is-visible=false")
				winset(C, "ops_ranks.expires", "is-visible=false")
				winset(C, "ops_ranks.days_label", "is-visible=false")
				winset(C, "ops_ranks.electable", "is-visible=false")
				winset(C, "ops_ranks.electable_by", "is-visible=false")
				winset(C, "ops_ranks.or_higher", "is-visible=false")
				winset(C, "ops_ranks.or_lower", "is-visible=false")
				winset(C, "ops_ranks.max_elect_label", "is-visible=false")
				winset(C, "ops_ranks.max_electable", "is-visible=false")
				winset(C, "ops_ranks.monitor", "is-visible=false")
				winset(C, "ops_ranks.auto_approve", "is-visible=false")
				winset(C, "ops_ranks.privileges_label", "is-visible=false")
				winset(C, "ops_ranks.privileges", "is-visible=false")
				winset(C, "ops_ranks.add_priv_button", "is-visible=false")
				winset(C, "ops_ranks.remove_priv_button", "is-visible=false")

			UpdateOpRanks()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				var/i = 0
				for(var/OpRank/Rank in OpMan.op_ranks)
					Rank.oprank = 0
					Rank.oplist = 0
					if(Rank == C.RankSelect)
						winset(C, "ops_ranks.ranks", "style='body{background-color:#000066;color:#FFFFFF;}'")
						winset(C, "ops_ranks.ranks", "current-cell='1,[++i]'")
						C << output(Rank.select, "ops_ranks.ranks")
						winset(C, "ops_ranks.ranks", "style=''")
					else
						winset(C, "ops_ranks.ranks", "current-cell='1,[++i]'")
						C << output(Rank.select, "ops_ranks.ranks")
				winset(C, "ops_ranks.ranks", "cells=1x[i]")
				if(C.RankSelect)
					winset(C, "ops_ranks.name", "text='[escapeQuotes(C.RankSelect.name)]'")
					winset(C, "ops_ranks.description", "text='[escapeQuotes(C.RankSelect.desc)]'")
					winset(C, "ops_ranks.promote", "text='[escapeQuotes(C.RankSelect.promote)]'")
					winset(C, "ops_ranks.demote", "text='[escapeQuotes(C.RankSelect.demote)]'")
					winset(C, "ops_ranks.color_button", "background-color='[escapeQuotes(C.RankSelect.color)]'")
					winset(C, "ops_ranks.color", "text='[escapeQuotes(C.RankSelect.color)]'")
					winset(C, "ops_ranks.temporary", "is-checked='[C.RankSelect.temp? "true" : "false"]'")
					winset(C, "ops_ranks.expires", "text='[C.RankSelect.expires]'")
					winset(C, "ops_ranks.electable", "is-checked='[C.RankSelect.elect? "true" : "false"]'")
					winset(C, "ops_ranks.electable_by", "text='[escapeQuotes(C.RankSelect.elect_by)]'")
					winset(C, "ops_ranks.or_higher", "is-checked='[C.RankSelect.or_higher? "true" : "false"]'")
					winset(C, "ops_ranks.or_lower", "is-checked='[C.RankSelect.or_lower? "true" : "false"]'")
					winset(C, "ops_ranks.max_electable", "text='[C.RankSelect.max_elect]'")
					winset(C, "ops_ranks.monitor", "is-checked='[C.RankSelect.monitor? "true" : "false"]'")
					winset(C, "ops_ranks.auto_approve", "is-checked='[C.RankSelect.auto_approve? "true" : "false"]'")
					if(!C.RankSelect.temp)
						winset(C, "ops_ranks.expires_label", "is-disabled=true;text-color=#C0C0C0")
						winset(C, "ops_ranks.expires", "is-disabled=true;background-color=#C0C0C0")
						winset(C, "ops_ranks.days_label", "is-disabled=true")
					else
						winset(C, "ops_ranks.expires_label", "is-disabled=false;text-color=#333333")
						winset(C, "ops_ranks.expires", "is-disabled=false;background-color=#FFFFFF")
						winset(C, "ops_ranks.days_label", "is-disabled=false")
					if(!C.RankSelect.elect)
						winset(C, "ops_ranks.electable_by", "is-disabled=true;background-color=#C0C0C0")
						winset(C, "ops_ranks.or_higher", "is-disabled=true")
						winset(C, "ops_ranks.or_lower", "is-disabled=true")
						winset(C, "ops_ranks.max_elect_label", "is-disabled=true")
						winset(C, "ops_ranks.max_electable", "is-disabled=true;background-color=#C0C0C0")
					else
						winset(C, "ops_ranks.electable_by", "is-disabled=false;background-color=#FFFFFF")
						winset(C, "ops_ranks.or_higher", "is-disabled=false")
						winset(C, "ops_ranks.or_lower", "is-disabled=false")
						winset(C, "ops_ranks.max_elect_label", "is-disabled=false")
						winset(C, "ops_ranks.max_electable", "is-disabled=false;background-color=#FFFFFF")
					i=0
					for(var/priv in C.RankSelect.privs)
						var/OpPrivilege/Priv = OpMan.op_privileges[priv]
						if(isnull(Priv)) continue
						Priv.ranklist = 1
						if(Priv == C.PrivSelect)
							winset(C, "ops_ranks.privileges", "style='body{background-color:#000066;color:#FFFFFF;}'")
							winset(C, "ops_ranks.privileges", "current-cell='1,[++i]'")
							C << output(Priv.select, "ops_ranks.privileges")
							winset(C, "ops_ranks.privileges", "style=''")
						else
							winset(C, "ops_ranks.privileges", "current-cell='1,[++i]'")
							C << output(Priv.select, "ops_ranks.privileges")
					winset(C, "ops_ranks.privileges", "cells=1x[i]")

			UpdateOpRankPrivileges()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				var/i=0
				for(var/priv in C.RankSelect.privs)
					var/OpPrivilege/Priv = OpMan.op_privileges[priv]
					if(isnull(Priv)) continue
					Priv.ranklist = 1
					if(Priv == C.PrivSelect)
						winset(C, "ops_ranks.privileges", "style='body{background-color:#000066;color:#FFFFFF;}'")
						winset(C, "ops_ranks.privileges", "current-cell='1,[++i]'")
						C << output(Priv.select, "ops_ranks.privileges")
						winset(C, "ops_ranks.privileges", "style=''")
					else
						winset(C, "ops_ranks.privileges", "current-cell='1,[++i]'")
						C << output(Priv.select, "ops_ranks.privileges")
				winset(C, "ops_ranks.privileges", "cells=1x[i]")

			DeleteOpRank()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				if(!C.RankSelect) return
				switch(alert(C, "Really?", "Delete Rank", "Yes", "No"))
					if("Yes")
						OpMan.op_ranks -= C.RankSelect
						fdel("./data/xml/ops/ranks/[C.RankSelect.name].xml")
						del(C.RankSelect)
						C.RankSelect = null
						var/i = 0
						for(var/OpRank/Rank in OpMan.op_ranks)
							winset(C, "ops_ranks.ranks", "current-cell='1,[++i]'")
							C << output(Rank.select, "ops_ranks.ranks")
						winset(C, "ops_ranks.ranks", "cells=1x[i]")
						call(C, "HideOpRankForm")()

			AddOpRankPrivilege()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.RankSelect) return
				var/priv = input(C, "Select a privilege to add.", "Add Privilege") as null | anything in OpMan.op_privileges
				if(!priv) return
				C.RankSelect.privs = listOpen(C.RankSelect.privs)
				C.RankSelect.privs += priv
				spawn(10) call(C, "UpdateOpRankPrivileges")()

			RemoveOpRankPrivilege()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.RankSelect || !C.PrivSelect) return
				C.RankSelect.privs -= C.PrivSelect.name
				listClose(C.RankSelect.privs)
				call(C, "UpdateOpRankPrivileges")()

			SetOpRankName(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!t || !C || !C.RankSelect) return
				C.RankSelect.name = t
				C.RankSelect.select.name = t
				winset(C, "ops_ranks.name", "text='[escapeQuotes(C.RankSelect.name)]'")
				call(C,"UpdateOpRanks")()

			SetOpRankDesc(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!t || !C || !C.RankSelect) return
				C.RankSelect.desc = t
				winset(C, "ops_ranks.description", "text='[escapeQuotes(C.RankSelect.desc)]'")

			SetOpRankPromote(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!t || !C || !C.RankSelect) return
				C.RankSelect.promote = t
				winset(C, "ops_ranks.promote", "text='[escapeQuotes(C.RankSelect.promote)]'")

			SetOpRankDemote(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!t || !C || !C.RankSelect) return
				C.RankSelect.demote = t
				winset(C, "ops_ranks.demote", "text='[escapeQuotes(C.RankSelect.demote)]'")

			SetOpRankColor(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!t || !C || !C.RankSelect) return
				C.RankSelect.color = t
				winset(C, "ops_ranks.color_button", "background-color='[escapeQuotes(C.RankSelect.color)]'")
				winset(C, "ops_ranks.color", "text='[escapeQuotes(C.RankSelect.color)]'")

			SetOpRankTemp()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.RankSelect) return
				if(C.RankSelect.temp)
					C.RankSelect.temp = 0
					winset(C, "ops_ranks.expires_label", "is-disabled=true;text-color=#C0C0C0")
					winset(C, "ops_ranks.expires", "is-disabled=true;background-color=#C0C0C0")
					winset(C, "ops_ranks.days_label", "is-disabled=true")
				else
					C.RankSelect.temp = 1
					winset(C, "ops_ranks.expires_label", "is-disabled=false;text-color=#333333")
					winset(C, "ops_ranks.expires", "is-disabled=false;background-color=#FFFFFF")
					winset(C, "ops_ranks.days_label", "is-disabled=false")

			SetOpRankExpires(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!t || !C || !C.RankSelect) return
				C.RankSelect.expires = text2num(t)
				winset(C, "ops_ranks.expires", "text='[C.RankSelect.expires]'")

			SetOpRankElect()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.RankSelect) return
				if(C.RankSelect.elect)
					C.RankSelect.elect = 0
					winset(C, "ops_ranks.electable_by", "is-disabled=true;background-color=#C0C0C0")
					winset(C, "ops_ranks.or_higher", "is-disabled=true")
					winset(C, "ops_ranks.or_lower", "is-disabled=true")
					winset(C, "ops_ranks.max_elect_label", "is-disabled=true")
					winset(C, "ops_ranks.max_electable", "is-disabled=true;background-color=#C0C0C0")
				else
					C.RankSelect.elect = 1
					winset(C, "ops_ranks.electable_by", "is-disabled=false;background-color=#FFFFFF")
					winset(C, "ops_ranks.or_higher", "is-disabled=false")
					winset(C, "ops_ranks.or_lower", "is-disabled=false")
					winset(C, "ops_ranks.max_elect_label", "is-disabled=false")
					winset(C, "ops_ranks.max_electable", "is-disabled=false;background-color=#FFFFFF")

			SetOpRankElectBy(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!t || !C || !C.RankSelect) return
				C.RankSelect.elect_by = t
				winset(C, "ops_ranks.electable_by", "text='[escapeQuotes(C.RankSelect.elect_by)]'")

			SetOpRankOrHigher()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.RankSelect) return
				C.RankSelect.or_higher = 1
				C.RankSelect.or_lower = 0

			SetOpRankOrLower()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.RankSelect) return
				C.RankSelect.or_higher = 0
				C.RankSelect.or_lower = 1

			SetOpRankMaxElect(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!t || !C || !C.RankSelect) return
				C.RankSelect.max_elect = text2num(t)
				winset(C, "ops_ranks.max_electable", "text='[C.RankSelect.max_elect]'")

			SetOpRankMonitor()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.RankSelect) return
				if(C.RankSelect.monitor) C.RankSelect.monitor = 0
				else C.RankSelect.monitor = 1

			SetOpRankApprove()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.RankSelect) return
				if(C.RankSelect.auto_approve) C.RankSelect.auto_approve = 0
				C.RankSelect.auto_approve = 1

			SetOpRankPos(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!t || !C || !C.RankSelect) return
				if(t == "up")
					if(C.RankSelect.pos==1) return
					var/OpRank/R = OpMan.op_ranks[C.RankSelect.pos-1]
					OpMan.op_ranks.Swap(C.RankSelect.pos, R.pos)
					C.RankSelect.pos --
					R.pos++
				else
					if(C.RankSelect.pos==OpMan.op_ranks.len) return
					var/OpRank/R = OpMan.op_ranks[C.RankSelect.pos+1]
					OpMan.op_ranks.Swap(C.RankSelect.pos, R.pos)
					C.RankSelect.pos ++
					R.pos--
				call(C, "UpdateOpRanks")()


