
OpsView

	proc
		Display(mob/chatter/C, page)
			switch(page)
				if("general")
					winset(C, "ops.general_button", "is-checked=true;")
					winset(C, "ops.settings_button", "is-checked=false;")
					winset(C, "ops.ranks_button", "is-checked=false;")
					winset(C, "ops.privileges_button", "is-checked=false;")
					winset(C, "ops.actions_button", "is-checked=false;")
					winset(C, "ops.monitor_button", "is-checked=false;")
					winset(C, "ops.child", "left=ops_general")
					call(C, "UpdateOperators")()
					call(C, "HideOperatorForm")()
				if("ranks")
					winset(C, "ops.general_button", "is-checked=false;")
					winset(C, "ops.settings_button", "is-checked=false;")
					winset(C, "ops.ranks_button", "is-checked=true;")
					winset(C, "ops.privileges_button", "is-checked=false;")
					winset(C, "ops.actions_button", "is-checked=false;")
					winset(C, "ops.monitor_button", "is-checked=false;")
					winset(C, "ops.child", "left=ops_ranks")
					C.RankSelect = null
					C.PrivSelectLeft = null
					C.PrivSelectRight = null
					call(C, "UpdateOpRanks")()
					call(C, "HideOpRankForm")()
				if("privileges")
					winset(C, "ops.general_button", "is-checked=false;")
					winset(C, "ops.settings_button", "is-checked=false;")
					winset(C, "ops.ranks_button", "is-checked=false;")
					winset(C, "ops.privileges_button", "is-checked=true;")
					winset(C, "ops.actions_button", "is-checked=false;")
					winset(C, "ops.monitor_button", "is-checked=false;")
					winset(C, "ops.child", "left=ops_privileges")
					C.PrivSelectLeft = null
					C.PrivSelectRight = null
					call(C, "UpdateOpPrivileges")()
					call(C, "HideOpPrivilegeForm")()
				if("actions")
					winset(C, "ops.general_button", "is-checked=false;")
					winset(C, "ops.settings_button", "is-checked=false;")
					winset(C, "ops.ranks_button", "is-checked=false;")
					winset(C, "ops.privileges_button", "is-checked=false;")
					winset(C, "ops.actions_button", "is-checked=true;")
					winset(C, "ops.monitor_button", "is-checked=false;")
					winset(C, "ops.child", "left=ops_actions")


		Initialize(mob/chatter/C)
			if(!C || !C.client) return
			for(var/p in typesof(/Operators/General/proc)-/Operators/General/proc)
				if(!(p:name in C.verbs)) C.verbs += p
			for(var/p in typesof(/Operators/Ranks/proc)-/Operators/Ranks/proc)
				if(!(p:name in C.verbs)) C.verbs += p
			for(var/p in typesof(/Operators/Privileges/proc)-/Operators/Privileges/proc)
				if(!(p:name in C.verbs)) C.verbs += p
			winset(C, "ops.general_button", "command='BrowseOpsGeneral';")
			winset(C, "ops.settings_button", "command='BrowseOpsSettings';")
			winset(C, "ops.ranks_button", "command='BrowseOpsRanks';")
			winset(C, "ops.privileges_button", "command='BrowseOpsPrivileges';")
			winset(C, "ops.actions_button", "command='BrowseOpsActions';")
			winset(C, "ops.monitor_button", "command='BrowseOpsMonitor';")
