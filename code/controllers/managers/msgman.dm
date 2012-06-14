
MessageManager
	var
		isIgnoredResult = 1

	Topic(href, href_list[])
		..()
		switch(href_list["action"])
			if("isIgnored")
				var/From = href_list["from"]
				var/T = href_list["to"]
				var/mob/chatter/To = ChatMan.Get(T,1)
				var/Addr = href_list["addr"]
				if(To.ignoring(From) & IM_IGNORE)
					world.Export("[Addr]?dest=msgman&action=isIgnoredResult&result=true")
				else
					world.Export("[Addr]?dest=msgman&action=isIgnoredResult&result=true")
			if("isIgnoredResult")
				isIgnoredResult = href_list["result"]
			if("msg")
				var/savefile/S = new(world.Import())
				var/mob/From, T, M
				S["to"] >> T
				S["from"] >> From
				S["msg"] >> M
				if(!ChatMan.Dummies) ChatMan.Dummies = new()
				ChatMan.Dummies += From
				var/mob/chatter/C = ChatMan.Get(T,1)
				RouteMsg(From,C,M)



	proc
		RouteMsg(mob/chatter/From, mob/chatter/To, msg, clean)
			if(!msg) return
			if(To.ignoring(From) & IM_IGNORE)
				alert(From, "[To.name] is ignoring instant messages from you.", "Unable to IM chatter.")
				return
			To.MsgHand.GetMsg(From, msg, clean)

		isIgnoring(Name)
			var/timeout = 300
			isIgnoredResult = null
			while(isnull(isIgnoredResult) && timeout--) sleep(1)
			return isIgnoredResult