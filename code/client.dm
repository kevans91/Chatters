
client
	authenticate = 0
	perspective = EDGE_PERSPECTIVE
	show_popup_menus = 0
	preload_rsc = 0

	Topic(href,href_list[],hsrc)
		..()
		href += "&source=[mob.name]"
		href_list = params2list(href)
		Console.Topic(href,href_list)


	Command(command)
		var/success=0
		if(findtext(command,"/",1,2))
			var/pos = findtext(command, " ")
			var/cmd = copytext(command, 2, pos)
			var/params
			if(pos) params = copytext(command, pos + 1)
			for(var/v in mob.verbs)
				if(ckey(cmd) == ckey(v:name))
					call(mob, v:name)(params)
					success=1
		if(!success) call(mob, "Say")(command)
		..(command)