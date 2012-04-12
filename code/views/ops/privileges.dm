Operators
	Privileges

		proc
			UpdateOperatorPrivilege()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return

			ShowOpPrivilegeForm()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return

				winset(C, "ops_privileges.name_label", "is-visible=true")
				winset(C, "ops_privileges.name", "is-visible=true")
				winset(C, "ops_privileges.description_label", "is-visible=true")
				winset(C, "ops_privileges.description", "is-visible=true")
				winset(C, "ops_privileges.execute_label", "is-visible=true")
				winset(C, "ops_privileges.execute", "is-visible=true")
				winset(C, "ops_privileges.command_label", "is-visible=true")
				winset(C, "ops_privileges.command", "is-visible=true")
				winset(C, "ops_privileges.electable", "is-visible=true")
				winset(C, "ops_privileges.electable_by", "is-visible=true")
				winset(C, "ops_privileges.or_higher", "is-visible=true")
				winset(C, "ops_privileges.or_lower", "is-visible=true")
				winset(C, "ops_privileges.min_votes_label", "is-visible=true")
				winset(C, "ops_privileges.min_votes", "is-visible=true")
				winset(C, "ops_privileges.min_delay_label", "is-visible=true")
				winset(C, "ops_privileges.min_delay", "is-visible=true")
				winset(C, "ops_privileges.margin_label", "is-visible=true")
				winset(C, "ops_privileges.margin", "is-visible=true")
				winset(C, "ops_privileges.monitor", "is-visible=true")
				winset(C, "ops_privileges.auto_approve_label", "is-visible=true")
				winset(C, "ops_privileges.auto_approve_yes", "is-visible=true")
				winset(C, "ops_privileges.auto_approve_no", "is-visible=true")
				winset(C, "ops_privileges.update_button", "is-visible=true")

			HideOpPrivilegeForm()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return

				winset(C, "ops_privileges.name_label", "is-visible=false")
				winset(C, "ops_privileges.name", "is-visible=false")
				winset(C, "ops_privileges.description_label", "is-visible=false")
				winset(C, "ops_privileges.description", "is-visible=false")
				winset(C, "ops_privileges.execute_label", "is-visible=false")
				winset(C, "ops_privileges.execute", "is-visible=false")
				winset(C, "ops_privileges.command_label", "is-visible=false")
				winset(C, "ops_privileges.command", "is-visible=false")
				winset(C, "ops_privileges.electable", "is-visible=false")
				winset(C, "ops_privileges.electable_by", "is-visible=false")
				winset(C, "ops_privileges.or_higher", "is-visible=false")
				winset(C, "ops_privileges.or_lower", "is-visible=false")
				winset(C, "ops_privileges.min_votes_label", "is-visible=false")
				winset(C, "ops_privileges.min_votes", "is-visible=false")
				winset(C, "ops_privileges.min_delay_label", "is-visible=false")
				winset(C, "ops_privileges.min_delay", "is-visible=false")
				winset(C, "ops_privileges.margin_label", "is-visible=false")
				winset(C, "ops_privileges.margin", "is-visible=false")
				winset(C, "ops_privileges.monitor", "is-visible=false")
				winset(C, "ops_privileges.auto_approve_label", "is-visible=false")
				winset(C, "ops_privileges.auto_approve_yes", "is-visible=false")
				winset(C, "ops_privileges.auto_approve_no", "is-visible=false")
				winset(C, "ops_privileges.update_button", "is-visible=false")

			UpdateOpPrivileges()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				var/i = 0
				for(var/priv in OpMan.op_privileges)
					var/OpPrivilege/Priv = OpMan.op_privileges[priv]
					Priv.ranklist = 0
					if(Priv == C.PrivSelectRight)
						winset(C, "ops_privileges.privileges", "style='body{background-color:#000066;color:#FFFFFF;}'")
						winset(C, "ops_privileges.privileges", "current-cell='1,[++i]'")
						C << output(C.PrivSelectRight.name, "ops_privileges.privileges")
						winset(C, "ops_privileges.privileges", "style=''")
					else
						winset(C, "ops_privileges.privileges", "current-cell='1,[++i]'")
						C << output(Priv.select, "ops_privileges.privileges")
				if(C.PrivSelectRight)
					winset(C, "ops_privileges.privileges", "cells=1x[i]")
					winset(C, "ops_privileges.name", "text='[escapeQuotes(C.PrivSelectRight.name)]'")
					winset(C, "ops_privileges.description", "text='[escapeQuotes(C.PrivSelectRight.desc)]'")
					winset(C, "ops_privileges.execute", "text='[escapeQuotes(C.PrivSelectRight.execute)]'")
					winset(C, "ops_privileges.command", "text='[escapeQuotes(C.PrivSelectRight.command)]'")
					winset(C, "ops_privileges.min_votes", "text='[C.PrivSelectRight.min_votes]'")
					winset(C, "ops_privileges.min_delay", "text='[C.PrivSelectRight.min_delay]'")
					winset(C, "ops_privileges.margin", "text='[C.PrivSelectRight.margin]%'")
					winset(C, "ops_privileges.electable", "is-checked='[C.PrivSelectRight.elect? "true" : "false"]'")
					winset(C, "ops_privileges.electable_by", "text='[escapeQuotes(C.PrivSelectRight.elect_by)]'")
					winset(C, "ops_privileges.or_higher", "is-checked='[C.PrivSelectRight.or_higher? "true" : "false"]'")
					winset(C, "ops_privileges.or_lower", "is-checked='[C.PrivSelectRight.or_lower? "true" : "false"]'")
					winset(C, "ops_privileges.monitor", "is-checked='[C.PrivSelectRight.monitor? "true" : "false"]'")
					winset(C, "ops_privileges.auto_approve_yes", "is-checked='[C.PrivSelectRight.auto_approve? "true" : "false"]'")
					winset(C, "ops_privileges.auto_approve_no", "is-checked='[C.PrivSelectRight.auto_approve? "false" : "true"]'")
					if(!C.PrivSelectRight.elect)
						winset(C, "ops_privileges.electable_by", "is-disabled=true;background-color=#C0C0C0")
						winset(C, "ops_privileges.or_higher", "is-disabled=true")
						winset(C, "ops_privileges.or_lower", "is-disabled=true")
						winset(C, "ops_privileges.min_votes", "is-disabled=true;background-color=#C0C0C0")
						winset(C, "ops_privileges.min_delay", "is-disabled=true;background-color=#C0C0C0")
						winset(C, "ops_privileges.margin", "is-disabled=true;background-color=#C0C0C0")
					else
						winset(C, "ops_privileges.electable_by", "is-disabled=false;background-color=#FFFFFF")
						winset(C, "ops_privileges.or_higher", "is-disabled=false")
						winset(C, "ops_privileges.or_lower", "is-disabled=false")
						winset(C, "ops_privileges.min_votes", "is-disabled=false;background-color=#FFFFFF")
						winset(C, "ops_privileges.min_delay", "is-disabled=false;background-color=#FFFFFF")
						winset(C, "ops_privileges.margin", "is-disabled=false;background-color=#FFFFFF")

			SetOpPrivilegeName(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!t || !C || !C.PrivSelectRight) return
				C.PrivSelectRight.name = t
				C.PrivSelectRight.select.name = t
				winset(C, "ops_privileges.name", "text='[escapeQuotes(C.PrivSelectRight.name)]'")
				call(C,"UpdateOpPrivileges")()

			SetOpPrivilegeDesc(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!t || !C || !C.PrivSelectRight) return
				C.PrivSelectRight.desc = t
				winset(C, "ops_privileges.description", "text='[escapeQuotes(C.PrivSelectRight.desc)]'")

			SetOpPrivilegeExecute(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!t || !C || !C.PrivSelectRight) return
				C.PrivSelectRight.execute = t
				winset(C, "ops_privileges.execute", "text='[escapeQuotes(C.PrivSelectRight.execute)]'")

			SetOpPrivilegeCommand(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!t || !C || !C.PrivSelectRight) return
				C.PrivSelectRight.command = t
				winset(C, "ops_privileges.command", "text='[escapeQuotes(C.PrivSelectRight.command)]'")

			SetOpPrivilegeElect()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.PrivSelectRight) return
				if(C.PrivSelectRight.elect)
					C.PrivSelectRight.elect = 0
					winset(C, "ops_privileges.electable_by", "is-disabled=true;background-color=#C0C0C0")
					winset(C, "ops_privileges.or_higher", "is-disabled=true")
					winset(C, "ops_privileges.or_lower", "is-disabled=true")
					winset(C, "ops_privileges.min_votes", "is-disabled=true;background-color=#C0C0C0")
					winset(C, "ops_privileges.min_delay", "is-disabled=true;background-color=#C0C0C0")
					winset(C, "ops_privileges.margin", "is-disabled=true;background-color=#C0C0C0")
				else
					C.PrivSelectRight.elect = 1
					winset(C, "ops_privileges.electable_by", "is-disabled=false;background-color=#FFFFFF")
					winset(C, "ops_privileges.or_higher", "is-disabled=false")
					winset(C, "ops_privileges.or_lower", "is-disabled=false")
					winset(C, "ops_privileges.min_votes", "is-disabled=false;background-color=#FFFFFF")
					winset(C, "ops_privileges.min_delay", "is-disabled=false;background-color=#FFFFFF")
					winset(C, "ops_privileges.margin", "is-disabled=false;background-color=#FFFFFF")

			SetOpPrivilegeElectBy(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!t || !C || !C.PrivSelectRight) return
				C.PrivSelectRight.elect_by = t
				winset(C, "ops_privileges.electable_by", "text='[escapeQuotes(C.PrivSelectRight.elect_by)]'")

			SetOpPrivilegeOrHigher()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.PrivSelectRight) return
				C.PrivSelectRight.or_higher = 1
				C.PrivSelectRight.or_lower = 0

			SetOpPrivilegeOrLower()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.PrivSelectRight) return
				C.PrivSelectRight.or_higher = 0
				C.PrivSelectRight.or_lower = 1

			SetOpPrivilegeMinVotes(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!t || !C || !C.PrivSelectRight) return
				C.PrivSelectRight.min_votes = abs(text2num(t))
				winset(C, "ops_privileges.min_votes", "text='[C.PrivSelectRight.min_votes]'")

			SetOpPrivilegeMinDelay(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!t || !C || !C.PrivSelectRight) return
				C.PrivSelectRight.min_delay = abs(text2num(t))
				winset(C, "ops_privileges.min_delay", "text='[C.PrivSelectRight.min_delay]'")

			SetOpPrivilegeMargin(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!t || !C || !C.PrivSelectRight) return
				C.PrivSelectRight.margin = abs(text2num(t))
				winset(C, "ops_privileges.margin", "text='[C.PrivSelectRight.margin]%'")

			SetOpPrivilegeMonitor()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C || !C.PrivSelectRight) return
				if(C.PrivSelectRight.monitor) C.PrivSelectRight.monitor = 0
				else C.PrivSelectRight.monitor = 1

			SetOpPrivilegeAutoApprove(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!t || !C || !C.PrivSelectRight) return
				C.PrivSelectRight.auto_approve = text2num(t)