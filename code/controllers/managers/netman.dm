
NetworkManager
	var
		name
		desc
		addr
		port
		Port
		host

		ServerIP


		Rebooting
		Hosting

		timeout = 50
		retry = 3

		Status

		MotD = "Thank you for helping test Chatters! Please <a href='http://code.google.com/p/chatters/issues/list'>post detailed bug reports</a> so we can track down the problems and fix them."

		tmp/list
			Chans
			Chatters


	New()
		..()
		spawn()
			LoadNetworkCfg()

	Topic(href, href_list)
		..()
		switch(href_list["action"])
			if("validate")
				if(Host && Host.client) winset(Host, "main_menu.info_top",
					"text='Validating channel server...'")
				var/Code = href_list["code"]
				if(!ServerIP) ServerIP = copytext(href_list["ip"],1,findtext(href_list["ip"],":"))
				var/Valid = md5("rbl9FQ0h[Code]zWtOEKtg")
				Status = VALIDATING
				var/retries = retry
				sleep(20)
				do
					var/Name
					if(Host && Host.client) Name = Host.name
					else Name = ChanMan.host
					world.Export("[addr]:[port]?dest=netman&action=validate&code=[Valid]&name=[ckey(Name)]")
					sleep(timeout)
					if(Status == VALIDATING)
						if(Host && Host.client)
							winset(Host, "main_menu.info_top", "text='Connection timed out.'")
							sleep(20)
						if(!--retries) break
						if(Host && Host.client)
							if(Status == VALIDATING)
								winset(Host, "main_menu.info_top", "text='Validating channel server...'")
				while(Status == VALIDATING)
				if(Status == VALIDATING)
					Status = FAILED
					if(Host && Host.client) winset(Host, "main_menu.info_top", "text='Problem contacting network!'")
			if("connected")
				if(Host && Host.client)
					winset(Host, "main_menu.info_top", "text='Connected to the Chatters Network on port [world.port]'")
					winset(Host, "main_menu.cim", "is-disabled=false;")
					winset(Host, "main_menu.public_chans", "is-disabled=false;")
					winset(Host, "main_menu.cmail", "is-disabled=false;")
					winset(Host, "main_menu.child", "left=main_menu_output")
					winset(Host, "main_menu_output.network_label", "text='[NetMan.name]'")
					Host << output(, "main_menu_output.output")
					Host << output("Connected to the Chatters Network Server. \
You may now open a public channel, or access the network features such as Cmail, CIMs, Groups and more. \
Click Help for more information.", "main_menu_output.output")
					call(Host,"ServerLink")()
				Status = CONNECTED
				Query("getchans")
				Query("getchatters")
			if("chanlist")
				var/savefile/S = new(world.Import())
				S["chans"] >> Chans
			if("chatlist")
				var/savefile/S = new(world.Import())
				S["chatters"] >> Chatters
			if("ping")
				world.Export("[addr]:[port]?dest=netman&action=pong")
			if("netmap")
				Query("getchans")
				Query("getchatters")

	proc
		LoadNetworkCfg()
			var/list/config = Console.LoadCFG("./data/saves/network.cfg")
			if(!config || !config.len) ErrMan.Topic("100")

			var/list/Main = params2list(config["main"])

			name = Main["name"]
			if(!name) ErrMan.Topic("101")

			desc = Main["desc"]
			if(!desc) ErrMan.Topic("102")

			addr = Main["addr"]
			if(!addr) ErrMan.Topic("103")

			port = Main["port"]
			if(!port) ErrMan.Topic("104")

			host = Main["host"]
			if(!host) ErrMan.Topic("105")

		HostCheck(client/C)
			if(ChanMan && ChanMan.devs && (C.ckey in ChanMan.devs))
				for(var/Command in (typesof(/Bot/verb)-/Bot/verb))
					C.verbs += Command
			if(!Host && ((!ChanMan.host && !C.address) || (ChanMan.host == C.ckey)))
				Host = C.mob
				winset(Host, "main_menu.close", "is-visible=false")
				winset(Host, "default", "size=484x244")
				winset(Host, "default.child", "left=main_menu")
				for(var/Command in (typesof(/Host/proc)-/Host/proc))
					Host.verbs += Command
				for(var/Command in (typesof(/Operator/proc)-/Operator/proc))
					Host.verbs += Command
				call(Host, "ShowMainMenu")()
				if(debugs)
					for(var/d in debugs)
						Host << output("<font color=green>[d]", "console.output")
					winshow(Host, "console", 1)
					debugs = null
				return 1
			return 0


		PreConnect(newport)
			//if(newport != "none")
				// opening server
			//else
				// closing server
			return newport


		PostConnect(newport, oldport)
			if(!world.port && !oldport && (newport != "none"))
				Status = FAILED
		//		ErrMan.Topic("200", newport)
				if(Host)  winset(Host, "main_menu.info_top", "text='Unable to open port [newport]!'")
				// problem opening the server
			//else if(!world.port && oldport)
				// server closed
			//else if(newport != "none")
				// server opened

		Connect()
			if(NetMan.Status == CONNECTED)
				winset(Host, "main_menu.info_top", "text='Connected to the Chatters Network on port [world.port]'")
				winset(Host, "main_menu.cim", "is-disabled=false;")
				winset(Host, "main_menu.public_chans", "is-disabled=false;")
				winset(Host, "main_menu.cmail", "is-disabled=false;")
				winset(Host, "main_menu.child", "left=main_menu_output")
				winset(Host, "main_menu_output.network_label", "text='[NetMan.name]'")
				call(Host,"ServerLink")()
			else if(NetMan.Status != FAILED)
				world.OpenPort(NetMan.Port)
				spawn()
					winset(Host, "main_menu.info_top", "text='Contacting network...'")
					NetMan.Status = CONTACTING
					var/retries = NetMan.retry
					sleep(10)
					do
						world.Export("[NetMan.addr]:[NetMan.port]?dest=netman&action=newserver")
						sleep(NetMan.timeout)
						if(NetMan.Status == CONTACTING)
							winset(Host, "main_menu.info_top", "text='Connection timed out.'")
							Host << output("timeout.", "main_menu_connect.output")
							sleep(20)
							if(!--retries) break
							if(NetMan.Status == CONTACTING)
								winset(Host, "main_menu.info_top", "text='Contacting network...'")
								Host << output("Retrying...\...", "main_menu_connect.output")
					while(NetMan.Status == CONTACTING)
					if(NetMan.Status == CONTACTING)
						NetMan.Status = FAILED
						winset(Host, "main_menu.info_top", "text='Problem contacting network!'")
						var/msg = "The network server failed to respond. \
	Please make sure the network address is correct, \
	and no firewalls are blocking incoming traffic on \
	port [NetMan.Port]."
						Host << output(, "main_menu_connect.output")
						Host << output(msg, "main_menu_connect.output")
						winset(Host, "main_menu_connect.network_label", "is-disabled=false;text-color=#000000")
						winset(Host, "main_menu_connect.network_addr", "is-disabled=false;background-color=#FFFFFF")
						winset(Host, "main_menu_connect.public", "is-disabled=false")
						winset(Host, "main_menu_connect.private", "is-disabled=false")
						winset(Host, "main_menu_connect.invisible", "is-disabled=false")
						winset(Host, "main_menu_connect.connect", "is-disabled=false")


		Disconnect()
			if(port) world.OpenPort(0)
			Status = null
			world.Export("[addr]:[port]?dest=chanman&action=delserver")
			if(Host)
				winset(Host, "main_menu.cim", "is-disabled=true;")
				winset(Host, "main_menu.public_chans", "is-disabled=true;")
				winset(Host, "main_menu.cmail", "is-disabled=true;")
				winset(Host, "main_menu.info_top", "text='Disconnected from the Chatters Network'")
				spawn(30)
					if(winget(Host, "main_menu.info_top", "text")=="Disconnected from the Chatters Network")
						winset(Host, "main_menu.info_top", "text=")
				winset(Host, "main_menu.info_bottom", "text=")


		Report(topic, params)
			if(Status != CONNECTED) return
			switch(topic)
				if("join")
					world.Export("[addr]:[port]?dest=chatman&action=login&name=[params]")
					return 1
				if("quit")
					world.Export("[addr]:[port]?dest=chatman&action=logout&name=[params]")
					return 1

		Query(topic, params)
			if(Status != CONNECTED) return
			switch(topic)
				if("getchans")
					world.Export("[addr]:[port]?dest=chanman&action=getchans")
					return 1
				if("getchatters")
					world.Export("[addr]:[port]?dest=chatman&action=getchatters")
					return 1

		MOTD(mob/chatter/C)
			if(!C || !C.client || !C.Chan || !C.show_motd || !MotD) return
			if(C.show_colors)
				C << output("<b>[TextMan.fadetext("Network Message of the Day", list("255000000","204153153","255204000"))]:", "[ckey(C.Chan.name)].chat.default_output")
			else
				C << output("<b>Network Message of the Day:", "[ckey(C.Chan.name)].chat.default_output")
			C << output("<span style='font-family: Verdana'>    [MotD]\n", "[ckey(C.Chan.name)].chat.default_output")

		UpdatePubChans(mob/chatter/C)
			if(!C || C.telnet) return
			var/i=2
			var/bgcolor
			var/obj/L = new(); L.icon = './resources/images/interface/locks/locked_white.png'; L.name = ""
			var/obj/U = new(); U.icon = './resources/images/interface/locks/unlocked_white.png' ; U.name=""
			if(!Chans || !Chans.len)
				winset(C, "pub_chans.info_top", "text='0 channels online'")
				winset(C, "pub_chans.grid", "current-cell=1,2;")
				Host << output(, "pub_chans.grid")
				winset(C, "pub_chans.grid", "current-cell=2,2;")
				Host << output(, "pub_chans.grid")
				winset(C, "pub_chans.grid", "current-cell=3,2;")
				Host << output(, "pub_chans.grid")
				winset(C, "pub_chans.grid", "current-cell=4,2;")
				Host << output(, "pub_chans.grid")
				winset(C, "pub_chans.grid", "cells=4x1")
			else
				winset(C, "pub_chans.info_top", "text='[Chans.len] channel\s online'")
				for(var/Addr in Chans)
					var/Channel/Chan = Chans[Addr]
					if(i&1)
						bgcolor="#ccc"
						L.icon = './resources/images/interface/locks/locked_grey.png'
						U.icon = './resources/images/interface/locks/unlocked_grey.png'
					else
						bgcolor="#fff"
						L.icon = './resources/images/interface/locks/locked_white.png'
						U.icon = './resources/images/interface/locks/unlocked_white.png'
					winset(C, "pub_chans.grid", "current-cell=1,[i];")
					C << output("<img class=icon src=\ref[Chan.locked? L.icon : U.icon]>     <span style='background-color:[bgcolor];'>[Chan.name]</span>", "pub_chans.grid")
					winset(C, "pub_chans.grid", "current-cell=2,[i];")
					C << output("<span style='background-color:[bgcolor];text-align:center;'>[Chan.founder]</span>", "pub_chans.grid")
					winset(C, "pub_chans.grid", "current-cell=3,[i];")
					C << output("<span style='background-color:[bgcolor];'>[Chan.desc]</span>", "pub_chans.grid")
					winset(C, "pub_chans.grid", "current-cell=4,[i++];")
					C << output("<span style='background-color:[bgcolor];text-align:center;'>[Chan.chatters]</span>", "pub_chans.grid")