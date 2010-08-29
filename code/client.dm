
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
		if(ChatMan.istelnet(key) && VERBOSE) //verbose
			src << "<font color='purple'>[command]</font>"

		var pos = findtext(command, " ")
		var cmd = copytext(command, 1, pos)
		var params
		if(pos) params = copytext(command, pos + 1)
		for(var/v in mob.verbs)
			if(ckey(cmd) == ckey(v:name))
				call(mob, v:name)(params)
		..(command)

	verb
		who()
			var /mob/chatter/c = mob
			c.Chan.UpdateWho()