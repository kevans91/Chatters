
Host
	proc
		SaveMap()
			var/swapmap/S = new("Paint",locate(1,1,1),locate(13,11,1))
			S.Save()
			del(S)

		getUndo()
			if(!Host || !Host.Painter) return
			Host << ftp(Host.Painter.Paint.undo_buffer, "./resources/icons/paint/undo.dmi")

		getRedo()
			if(!Host || !Host.Painter) return
			Host << ftp(Host.Painter.Paint.redo_buffer, "./resources/icons/paint/redo.dmi")

		addrTest()
			var/a_pos = findtext(world.address, ".", 1)
			var/b_pos = findtext(world.address, ".", a_pos+1)
			var/c_pos = findtext(world.address, ".", b_pos+1)
			var/a = num2hex(text2num(copytext(world.address, 1, a_pos))) + ascii2text(rand(103,122))
			var/b = num2hex(text2num(copytext(world.address, a_pos+1, b_pos))) + ascii2text(rand(103,122))
			var/c = num2hex(text2num(copytext(world.address, b_pos+1, c_pos))) + ascii2text(rand(103,122))
			var/d = num2hex(text2num(copytext(world.address, c_pos+1))) + ascii2text(rand(103,122))
			var/e = num2hex(world.port)
			debug(lowertext(a+b+c+d+e))
			debug(world.address+":[world.port]")
			debug(md5(world.address+":[world.port]"))

		NewChan()
			set hidden = 1
			var/OpenChannel/OC = new()
			OC.Display("new_chan")
			del(OC)

		LoadChan()
			set hidden = 1
			var/OpenChannel/OC = new()
			OC.Display("load_chan")
			del(OC)

		ShowOpenChannel()
			set hidden = 1
			winshow(Host, "open_chan", 1)
			var/OpenChannel/OC = new()
			OC.Display("index")
			del(OC)

		HideOpenChannel()
			set hidden = 1
			winshow(Host, "open_chan", 0)

		ShowConsole()
			set hidden = 1
			Console.Show()

		HideConsole()
			set hidden = 1
			Console.Hide()

		ShowMainMenu()
			set hidden = 1
			Host << output(null, "main_menu.output1")
			if(Host.picture)
				Host << output("<img src='[Host.picture]' width=64 height=64>\...", "main_menu.output1")
			else
				Host << output("<img src='./resources/images/noimage.png' width=64 height=64>\...", "main_menu.output1")
			winset(Host, "main_menu.key", "text='[Host.key]'")
			if(Home)
				winset(Host, "main_menu_box.child", "left=main_menu")
				winshow(Host, "main_menu_box", 1)
			winshow(Host, "main_menu", 1)
			winset(Host, "main_menu_connect.network_addr", "text='byond://[NetMan.addr]:[NetMan.port]'")

		HideMainMenu()
			set hidden = 1
			winshow(Host, "main_menu", 0)

		SetNetworkAddr(Addr as text|null)
			set hidden = 1
			var/protocol_end_pos = (findtext(Addr, "://") || 0)
			var/addr_end_pos = findtext(Addr, ":", protocol_end_pos+1)
			NetMan.addr = copytext(Addr, protocol_end_pos+1, addr_end_pos)
			NetMan.port = copytext(Addr, addr_end_pos+1)
			winset(Host, "main_menu_connect.network_addr", "text='byond://[NetMan.addr]:[NetMan.port]'")

		SetNetworkPublicity(t as text|null)
			set hidden = 1
			switch(t)
				if("public")
					world.visibility = 1
				if("private")
					world.visibility = 0
				if("invisible")
					world.visibility = 0

		Connect()
			set hidden = 1
			Host << output(, "main_menu_connect.output")
			Host << output("Connecting to the Chatters Network...\...", "main_menu_connect.output")
			winset(Host, "main_menu_connect.network_label", "is-disabled=true;text-color=#808080")
			winset(Host, "main_menu_connect.network_addr", "is-disabled=true;background-color=#c0c0c0")
			winset(Host, "main_menu_connect.public", "is-disabled=true")
			winset(Host, "main_menu_connect.private", "is-disabled=true")
			winset(Host, "main_menu_connect.invisible", "is-disabled=true")
			winset(Host, "main_menu_connect.connect", "is-disabled=true")
			NetMan.Connect()

		Disconnect()
			set hidden = 1
			winset(Host, "main_menu.child", "left=main_menu_connect")
			Host << output(, "main_menu_connect.output")
			Host << output("Disconnected from the Network Server.", "main_menu_connect.output")
			winset(Host, "main_menu_connect.network_label", "is-disabled=false;text-color=#000000")
			winset(Host, "main_menu_connect.network_addr", "is-disabled=false;background-color=#FFFFFF")
			winset(Host, "main_menu_connect.public", "is-disabled=false")
			winset(Host, "main_menu_connect.private", "is-disabled=false")
			winset(Host, "main_menu_connect.invisible", "is-disabled=false")
			winset(Host, "main_menu_connect.connect", "is-disabled=false")

		ServerLink(link as text|null)
			set hidden = 1
			winset(Host, "main_menu.info_bottom", "text='byond://[NetMan.ServerIP]:[world.port]'")

		EditSave(save as text|null)
			if(fexists(save))
				var/version
				var/filetext = ChatMan.EditSave(save)
				var/savefile/F = new(save)
				F["version"] >> version
				Host << browse({"
<HTML>
	<HEAD>
		<TITLE>Savefile Version: [version]</TITLE>
	</HEAD>

	<BODY>
		<PRE>[html_encode(filetext)]</PRE>
	<BODY>
</HTML>
"}, "window=EditSave")
			else alert(Host, "[save] does not exist.", "Savefile Not Found")