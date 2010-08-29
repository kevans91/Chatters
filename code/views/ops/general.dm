Operators
	General

		proc
			UpdateOperators()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.client || C.telnet) return

				winset(C, "ops_name_grid.grid", "style='body{background-color:#000066;color:#FFFFFF;font-weight:bold;}'")
				winset(C, "ops_rank_grid.grid", "style='body{background-color:#000066;color:#FFFFFF;font-weight:bold;}'")
				winset(C, "ops_action_grid.grid", "style='body{background-color:#000066;color:#FFFFFF;font-weight:bold;}'")
				winset(C, "ops_name_grid.grid", "current-cell=1,1")
				winset(C, "ops_rank_grid.grid", "current-cell=1,1")
				winset(C, "ops_action_grid.grid", "current-cell=1,1")
				C << output("Name:", "ops_name_grid.grid")
				C << output("Rank:", "ops_rank_grid.grid")
				C << output("Actions:", "ops_action_grid.grid")
				winset(C, "ops_name_grid.grid", "cells=1x1")
				winset(C, "ops_rank_grid.grid", "cells=1x1")
				winset(C, "ops_action_grid.grid", "cells=1x1")
				winset(C, "ops_name_grid.grid", "style=")
				winset(C, "ops_rank_grid.grid", "style=")
				winset(C, "ops_action_grid.grid", "style=")
				if(Home)
					var/i=2
					for(var/cKey in Home.operators)
						var/Op/O = Home.operators[cKey]
						if(O.NameSelect == C.NameSelect)
							winset(C, "ops_name_grid.grid", "style='body{background-color:#000066;color:#FFFFFF;}'")
							winset(C, "ops_rank_grid.grid", "style='body{background-color:#000066;color:#FFFFFF;}'")
							winset(C, "ops_action_grid.grid", "style='body{background-color:#000066;color:#FFFFFF;}'")
						winset(C, "ops_name_grid.grid", "current-cell=1,[i]")
						winset(C, "ops_rank_grid.grid", "current-cell=1,[i]")
						winset(C, "ops_action_grid.grid", "current-cell=1,[i]")
						C << output(O.NameSelect, "ops_name_grid.grid")
						C << output(O.RankSelect, "ops_rank_grid.grid")
						C << output(O.ActionsSelect, "ops_action_grid.grid")
						winset(C, "ops_name_grid.grid", "cells=1x[i]")
						winset(C, "ops_rank_grid.grid", "cells=1x[i]")
						winset(C, "ops_action_grid.grid", "cells=1x[i++]")
						if(O.NameSelect == C.NameSelect)
							winset(C, "ops_name_grid.grid", "style=''")
							winset(C, "ops_rank_grid.grid", "style=''")
							winset(C, "ops_action_grid.grid", "style=''")

			UpdateOpsGeneralForm()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.client || !C.Chan) return
				var/Name = winget(C, "ops_general.name", "text")
				var/cKey = ckey(Name)
				if(cKey)
					if(!C.RankSelect) C.RankSelect = OpMan.op_ranks[OpMan.op_ranks.len]
					if(cKey in C.Chan.operators)
						var/Op/Operator = C.Chan.operators[cKey]
						Operator.Rank = C.RankSelect
						Operator.RankSelect.name = C.RankSelect.name
						var/mob/chatter/M = ChatMan.Get(Name)
						if(ismob(M))
							for(var/priv in Operator.privileges)
								M.verbs -= text2path("/Operator/proc/[priv]")
							for(var/priv in Operator.Rank.privs)
								M.verbs += text2path("/Operator/proc/[priv]")
							C.Chan.UpdateWho()
						ChanMan.SaveChan(C.Chan)
					else
						var/Op/Operator = new(Name, C.RankSelect)
						var/mob/chatter/M = ChatMan.Get(Name)
						if(ismob(M))
							for(var/priv in Operator.Rank.privs)
								M.verbs += text2path("/Operator/proc/[priv]")
							C.Chan.UpdateWho()
						ChanMan.SaveChan(C.Chan)
				call(C, "HideOperatorForm")()
				if(cKey) call(C, "UpdateOperators")()

			ShowOperatorForm()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.client) return
				winset(C, "ops_general.name_label", "is-visible='true'")
				winset(C, "ops_general.name", "is-visible='true'")
				winset(C, "ops_general.rank_label", "is-visible='true'")
				winset(C, "ops_general.rank", "is-visible='true'")
				winset(C, "ops_general.update", "is-visible='true'")

			HideOperatorForm()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.client) return
				winset(C, "ops_general.name_label", "is-visible='false'")
				winset(C, "ops_general.name", "is-visible='false'")
				winset(C, "ops_general.rank_label", "is-visible='false'")
				winset(C, "ops_general.rank", "is-visible='false'")
				winset(C, "ops_general.update", "is-visible='false'")

			NewOperator()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.client) return
				C.NameSelect = null
				winset(C, "ops_general.name", "text=''")
				call(C, "UpdateOperators")()
				call(C, "ShowOperatorForm")()
				winset(C, "ops_general.rank", "current-cell='1,1'")
				var/OpRank/Rank = OpMan.op_ranks[OpMan.op_ranks.len]
				Rank.oprank = 1
				C << output(Rank.select, "ops_general.rank")
				winset(C, "ops_general.rank", "cells='1x1'")

			EditOperator()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.client || !C.NameSelect) return
				call(C, "ShowOperatorForm")()
				winset(C, "ops_general.rank", "current-cell='1,1'")
				var/OpRank/Rank = C.NameSelect.Op.Rank
				Rank.oprank = 1
				C << output(Rank.select, "ops_general.rank")
				winset(C, "ops_general.rank", "cells='1x1'")
				winset(C, "ops_general.name", "text='[C.NameSelect.Op.name]'")

			RemoveOperator()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.client || !C.NameSelect) return
				switch(alert(C, "Really?", "Delete Rank", "Yes", "No"))
					if("Yes")
						var/cKey = ckey(C.NameSelect.Op.name)
						C.Chan.operators[cKey] = null
						C.Chan.operators -= cKey
						var/mob/chatter/M = ChatMan.Get(C.NameSelect.Op.name)
						if(ismob(M))
							for(var/priv in C.NameSelect.Op.privileges)
								M.verbs -= text2path("/Operator/proc/[priv]")
							C.Chan.UpdateWho()
						C.NameSelect = null
						call(C, "HideOperatorForm")()
						call(C, "UpdateOperators")()
						ChanMan.SaveChan(C.Chan)

			ShowOpRankSelect()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.client) return
				var/i=0
				for(var/OpRank/Rank in OpMan.op_ranks)
					Rank.oprank = 0
					Rank.oplist = 1
					winset(C, "ops_general.rank_select", "current-cell='[++i]'")
					C << output(Rank.select, "ops_general.rank_select")
				winset(C, "ops_general.rank_select", "cells='1x[i]'")
				winset(C, "ops_general.rank_select", "is-visible='true'")

			HideOpRankSelect()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.client) return
				winset(C, "ops_general.rank_select", "is-visible='false'")
				winset(C, "ops_general.rank", "current-cell='1,1'")
				var/OpRank/Rank = C.RankSelect
				Rank.oprank = 1
				Rank.oplist = 0
				C << output(Rank.select, "ops_general.rank")
				winset(C, "ops_general.rank", "cells='1x1'")
