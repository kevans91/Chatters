
ChannelManager
	var/host
	var/telnet_pass
	var/telnet_attempts
	var/NameResult=1
	var/list/devs

	New()
		..()
		spawn()
			LoadServerCfg()

	Del()
		if(Home) SaveChan(Home)
		..()

	Topic(href, href_list[])
		..()
		switch(href_list["action"])
			if("namecheck")
				if(NetMan.Status != CONNECTED)
					alert(Host, "You are not currently connected to the Chatters network. You may create a private channel, but you may need to change its name if you wish go connect publicly to the network.", "Unable to Check Name")
					return
				var/result = isTaken(href_list["Name"])
				if(result) alert(Host, "[href_list["Name"]] is already in use.", "Name Taken")
				else alert(Host, "[href_list["Name"]] is free!", "Name Available")
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
			if("connected")
				NetMan.Status = CONNECTED
				if(Host && Host.client)
					winset(Host, "main_menu.info_top", "text='Channel successfully published to the network.'")
					sleep(30)
					winset(Host, "main_menu.info_top", "text='Connected to the Chatters Network on port [world.port]'")
					Host << output("Hosting [Home.name]", "main_menu_output.output")
				NetMan.Query("getchans")
				NetMan.Query("getchatters")
			if("checkedname")
				var/result = href_list["result"]
				if(NameResult)
					world.log << "Failed the name check."
					world.visibility = 0
					NetMan.Status = FAILED
					if(Host && Host.client)
						spawn() alert(Host, "The name you chose for your channel is already in use. Plaese choose a different name before reconnecting to the network.","Network Disconnected")

				else
					if(result == "true") NameResult = TRUE
					else NameResult = FALSE

	proc
		NewChan(list/params)
			var/Channel/Chan = new(params)
			Home = Chan
			ProcessChan()

		DelChan(chan)
			fdel("./data/saves/channels/[chan].sav")

		isTaken(Name)
			var/timeout = 300
			NameResult = null
			world.Export("[NetMan.addr]:[NetMan.port]?dest=chanman&action=checkname&name=[Name]")
			while(isnull(NameResult) && timeout--) sleep(1)
			return NameResult

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
			if(Home.publicity == "public")
				world.log << "Home channel is LIVE"
				world.visibility = 1
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
			NetMan.Status = CONNECTING
			var/retries = NetMan.retry
			spawn(20)
				do
					world.Export("[NetMan.addr]:[NetMan.port]?dest=chanman&action=connect",F)
					sleep(NetMan.timeout)
					if(NetMan.Status == CONNECTING)
						if(Host && Host.client) winset(Host, "main_menu.info_top", "text='Connection timed out.'")
						sleep(20)
						if(!--retries) break
						if(NetMan.Status == CONNECTING)
							if(Host && Host.client) winset(Host, "main_menu.info_top", "text='Publishing channel to the network...'")
				while(NetMan.Status == CONNECTING)
				if(NetMan.Status == CONNECTING || NetMan.Status == FAILED)
					NetMan.Status = FAILED
					if(Host && Host.client)
						winset(Host, "main_menu.info_top", "text='Problem contacting network!'")
						winset(Host, "main_menu.cim", "is-disabled=true;")
						winset(Host, "main_menu.public_chans", "is-disabled=true;")
						winset(Host, "main_menu.cmail", "is-disabled=true;")
						winset(Host, "main_menu.info_bottom", "text=")
				fdel("packet")


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
			S["mute"]		>> Chan.mute
			S["banned"]		>> Chan.banned
			if(!Chan.telnet_pass && telpass) Chan.telnet_pass = telpass
			if(!Chan.telnet_attempts && telatmpts) Chan.telnet_attempts = telatmpts
			return Chan

		LoadServerCfg()
			var/list/config = Console.LoadCFG("./data/saves/server.cfg")
			if(!config || !config.len) return

			var/list/H = params2list(config["main"])
			if(!H || !H.len) return
			host = ckey(H["host"])
			NetMan.Port = text2num(H["port"])

			var/list/D = params2list(config["devs"])
			if(D && D.len)
				if(!devs) devs = new
				for(var/d in D) devs += ckey(D[d])

		//	var/list/O = params2list(config["ops"])
		//	if(O && O.len) sleep()

		//	var/list/M = params2list(config["mute"])
		//	if(M && M.len) sleep()

		//	var/list/B = params2list(config["bans"])
		//	if(B && B.len) sleep()

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
						world.log << "My publicity: [Publicity]"
						if(Publicity == "public")
							world.log << "Opening world to public"
							world.visibility = 1

						Home.chanbot.SetName(botName)
						Home.chanbot.SetNameColor("#"+botNameColor)
						Home.chanbot.SetTextColor("#"+botTextColor)
						Home.chanbot.SetSpamControl(botSpamControls)
						Home.chanbot.SetSpamLimit(botSpamLimit)
						Home.chanbot.SetFloodLimit(botFloodLimit)
						Home.chanbot.SetSmileysLimit(botSmileysLimit)
						Home.chanbot.SetMaxMsgs(botMaxMsgs)
						Home.chanbot.SetMinDelay(botMinDelay)

						if(NetMan.Status != FAILED) spawn()
							NetMan.Status = CONTACTING
							var/retries = NetMan.retry
							sleep(10)
							do
								world.Export("[NetMan.addr]:[NetMan.port]?dest=netman&action=newserver")
								sleep(NetMan.timeout)
								if(NetMan.Status == CONTACTING) if(!--retries) break
							while(NetMan.Status == CONTACTING)
							if(NetMan.Status == CONTACTING)
								NetMan.Status = FAILED
								return

							var/a_pos = findtext(world.address, ".", 1)
							var/b_pos = findtext(world.address, ".", a_pos+1)
							var/c_pos = findtext(world.address, ".", b_pos+1)
							var/a = num2hex(text2num(copytext(world.address, 1, a_pos))) + ascii2text(rand(103,122))
							var/b = num2hex(text2num(copytext(world.address, a_pos+1, b_pos))) + ascii2text(rand(103,122))
							var/c = num2hex(text2num(copytext(world.address, b_pos+1, c_pos))) + ascii2text(rand(103,122))
							var/d = num2hex(text2num(copytext(world.address, c_pos+1))) + ascii2text(rand(103,122))
							var/e = num2hex(world.port)

							world.status = "<span style=\"color:#2a4680;\">[lowertext(a+b+c+d+e)]</span><br>[Home.name] founded by [Home.founder]"
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
							NetMan.Status = CONNECTING
							sleep(20)
							do
								world.Export("[NetMan.addr]:[NetMan.port]?dest=chanman&action=connect",F)
								sleep(NetMan.timeout)
								if(NetMan.Status == CONNECTING) if(!--retries) break
							while(NetMan.Status == CONNECTING)
							if(NetMan.Status == CONNECTING) NetMan.Status = FAILED
					else
						Home = LoadChan(HomeChan, telnet_pass, telnet_attempts)
						ProcessChan()