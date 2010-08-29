
EventManager

	proc
		Parse(mob/chatter/C, event)
			var/start_len = 2
			var/start_parenth = findtext(event,"(\"")
			if(!start_parenth)
				start_parenth = findtext(event,"( \"")
				start_len = 3
			if(!start_parenth)
				start_parenth = findtext(event,"( ")
			if(!start_parenth)
				start_parenth = findtext(event,"(")
				start_len = 1
			var/cmd = copytext(event, 1, start_parenth)
			var/end_parenth = findtext(event, "\")")
			if(!end_parenth) end_parenth = findtext(event,"\" )")
			if(!end_parenth) end_parenth = findtext(event," )")
			if(!end_parenth) end_parenth = findtext(event,")")
			var/params = copytext(event, start_parenth+start_len,end_parenth)
			for(var/v in C.verbs)
				if(ckey(cmd) == ckey(v:name))
					call(C, v:name)(params)