
ChannelManager
	var/host
	var/port
	var/telnet_pass
	var/telnet_attempts
	var/NameResult=1
	var/list/devs

	New(var/ServerConsole/console)
		..()
		LoadServerCfg(console)

	Del()
		if(Home) SaveChan(Home)
		..()

	Topic(href, href_list[])
		..()
		switch(href_list["action"])
			if("newchan")
				NewChan(href_list)
			if("loadchan")
				Home = LoadChan(href_list["chan"])
				Home.chanbot = BotMan.LoadBot(Home)
				ProcessChan()
			if("delchan")
				switch(alert("Are you sure you want to delete [href_list["chan"]]?", "Confirm Delete", "Yes", "No"))
					if("Yes") DelChan(href_list["chan"])
				var/OpenChannel/OC = new()
				OC.Display("load_chan")
				del(OC)

	proc
		NewChan(list/params)
			var/Channel/Chan = new(params)
			Home = Chan
			ProcessChan()

		DelChan(chan)
			fdel("./data/saves/channels/[chan].sav")

		isTaken(Name)
			return 0

		Join(mob/chatter/C, Channel/Chan)
			Chan.Join(C)

		Quit(mob/chatter/C, Channel/Chan)
			Chan.Quit(C)

		Say(mob/chatter/C, msg)
			C.Chan.Say(C, msg)

		ProcessChan()
			Home.LoadOps()
			SaveChan(Home)
			BotMan.SaveBot(Home.chanbot)
			if(Host && Host.client)
				call(Host,"Join")(Home)
				winshow(Host, "open_chan", 0)
				winset(Host, "main_menu.info_top", "text='Publishing channel to the network...'")
			world.status = "[Home.name] founded by [Home.founder] - [(Home.chatters ? Home.chatters.len : 0)] chatter\s"
			if(Home.publicity != "public") world.visibility = 0
			var/savefile/F = new("packet")
			F["founder"] << Home.founder
			F["name"] << Home.name
			F["desc"] << Home.desc
			F["topic"] << Home.topic
			F["password"] << Home.pass
			F["locked"] << Home.locked
			F["chatters"] << (Home.chatters ? Home.chatters.len : 0)
			F["supernode"] << Home.SuperNode
			F["maxnodes"] << Home.MaxNodes

		SaveChan(Channel/Chan)
			var/savefile/S = new("./data/saves/channels/[ckey(Chan.name)].sav")
			S["founder"]	<< Chan.founder
			S["name"]		<< Chan.name
			S["publicity"]	<< Chan.publicity
			S["desc"]		<< Chan.desc
			S["room_desc"] << Chan.room_desc
			S["room_desc_size"] << Chan.room_desc_size
			S["topic"]		<< Chan.topic
			S["pass"]		<< Chan.pass
			S["locked"]		<< Chan.locked
			S["telpass"]	<< Chan.telnet_pass
			S["telatmpts"]	<< Chan.telnet_attempts
			S["mute"]		<< Chan.mute
			S["banned"]		<< Chan.banned
			if(Chan.operators && Chan.operators.len)
				var/list/ops = new()
				for(var/cKey in Chan.operators)
					var/Op/O = Chan.operators[cKey]
					ops += O.name
					ops[O.name] = O.Rank.pos
				S["operators"]  << ops

		LoadChan(chan, telpass, telatmpts)
			var/savefile/S = new("./data/saves/channels/[ckey(chan)].sav")
			var/Channel/Chan = new()
			S["founder"]	>> Chan.founder
			S["name"]		>> Chan.name
			S["publicity"]	>> Chan.publicity
			S["desc"]		>> Chan.desc
			S["room_desc"]	>> Chan.room_desc
			S["room_desc_size"] >> Chan.room_desc_size
			S["topic"]		>> Chan.topic
			S["pass"]		>> Chan.pass
			S["locked"]		>> Chan.locked
			Chan.telnet_pass = telnet_pass
			Chan.telnet_attempts = telnet_attempts
			if(!Chan.telnet_pass && telpass) Chan.telnet_pass = telpass
			if(!Chan.telnet_attempts && telatmpts) Chan.telnet_attempts = telatmpts
			S["mute"]		>> Chan.mute
			S["banned"]		>> Chan.banned
			return Chan

		LoadServerCfg(var/ServerConsole/console)
			var/list/config = console.LoadCFG("./data/saves/server.cfg")
			if(!config || !config.len) return

			var/list/H = params2list(config["main"])
			if(!H || !H.len) return
			host = ckey(H["host"])
			port = text2num(H["port"])

			var/list/D = params2list(config["devs"])
			if(D && D.len)

				if(!devs) devs = new
				for(var/d in D) devs += ckey(D[d])

			var/list/muteList = params2list(config["mute"])
			var/list/banList = params2list(config["bans"])
			var/list/opList = params2list(config["ops"])

			var/list/S = params2list(config["server"])
			if(S && S.len)

				telnet_pass    = S["telnet_pass"]
				telnet_attempts    = (text2num(S["telnet_attempts"]) || -1)

				var/AutoStart = text2num(S["auto_start"]) ? 1 : 0
				if(AutoStart)
					var/HomeChan = S["home_chan"]
					if(!HomeChan)
						return
					else if(!fexists("./data/saves/channels/[ckey(HomeChan)].sav"))
						var/Password  = S["password"]
						var/Founder   = S["founder"]
						var/ChanDesc  = S["desc"]
						var/ChanTopic = S["topic"]
						var/SuperNode = text2num(S["super_name"]) ? 1 : 0
						var/MaxNodes  = text2num(S["max_nodes"])
						var/Publicity = S["publicity"]
						var/Locked    = S["locked"]

						var/botName        = S["bot_name"]
						var/botNameColor   = S["bot_name_color"]
						var/botTextColor   = S["bot_text_color"]

						var/botSpamControls= text2num(S["bot_spam_control"]) ? 1 : 0
						var/botSpamLimit   = text2num(S["bot_spam_limit"])
						var/botFloodLimit  = text2num(S["bot_flood_limit"])
						var/botSmileysLimit= text2num(S["bot_smileys_limit"])
						var/botMaxMsgs     = text2num(S["bot_max_msgs"])
						var/botMinDelay    = text2num(S["bot_min_delay"])

						Home = new(list(
							"Founder"=Founder,
							"Name"=HomeChan,
							"Publicity"=Publicity,
							"Desc"=ChanDesc,
							"Topic"=ChanTopic,
							"Pass"=Password,
							"Locked"=Locked,
							"TelPass"=telnet_pass,
							"TelAtmpts"=telnet_attempts,
							"SuperNode"=SuperNode,
							"MaxNodes"=MaxNodes))
						if(Publicity != "public") world.visibility = 0

						Home.chanbot.SetName(botName)
						Home.chanbot.SetNameColor("#"+botNameColor)
						Home.chanbot.SetTextColor("#"+botTextColor)
						Home.chanbot.SetSpamControl(botSpamControls)
						Home.chanbot.SetSpamLimit(botSpamLimit)
						Home.chanbot.SetFloodLimit(botFloodLimit)
						Home.chanbot.SetSmileysLimit(botSmileysLimit)
						Home.chanbot.SetMaxMsgs(botMaxMsgs)
						Home.chanbot.SetMinDelay(botMinDelay)

						if(muteList && muteList.len)
							Home.mute = new
							for(var/i in muteList)
								Home.mute += ckey(i)

						if(banList && banList.len)
							Home.banned = new
							for(var/i in banList)
								Home.banned += ckey(i)

						if(opList && opList.len)
							Home.operators = new
							for(var/Name in opList)
								if(!findtext(Name, "_"))
									var/opKey = ckey(opList[Name])
									var/rankIndex = text2num(opList["[Name]_level"])
/*									var/rankPrivs = opList[Name + "_privs"]	// Not sure what to do with this.
									if(rankPrivs != "default")
										// Do something
*/
									var/OpRank/Rank = Home.op_ranks[rankIndex]
									Home.operators[opKey] = new/Op(opList[Name], Rank)

							var/savefile/F = new()
							F["founder"] << Home.founder
							F["name"] << Home.name
							F["desc"] << Home.desc
							F["topic"] << Home.topic
							F["password"] << Home.pass
							F["locked"] << Home.locked
							F["supernode"] << Home.SuperNode
							F["maxnodes"] << Home.MaxNodes
							if(Home.chatters)
								F["chatters"] << Home.chatters.len
							else
								F["chatters"] << 0
					else
						Home = LoadChan(HomeChan, telnet_pass, telnet_attempts)
						Home.chanbot = BotMan.LoadBot(Home)
						Home.LoadOps()
						if(muteList && muteList.len)
							Home.mute = listOpen(Home.mute)
							for(var/i in muteList)
								var/cval = ckey(i)
								if(!(cval in Home.mute)) Home.mute += cval

						if(banList && banList.len)
							Home.banned = listOpen(Home.banned)
							for(var/i in banList)
								var/cval = ckey(i)
								if(!(cval in Home.banned)) Home.banned += cval

/*						if(opList && opList.len)
							Home.operators = listOpen(Home.operators)
							for(var/Name in opList)
								if(!findtext(Name, "_"))
									var/opKey = ckey(opList[Name])
									var/rankIndex = text2num(opList["[Name]_level"])
									var/rankPrivs = opList[Name + "_privs"]	// Not sure what to do with this.
									if(rankPrivs != "default")
										// Do something
*/
									var/OpRank/Rank = Home.op_ranks[rankIndex]
									Home.operators[opKey] = new/Op(opList[Name], Rank)
					// TODO: Remove this once the Chatters Network is properly implemented.
					world.OpenPort(port)