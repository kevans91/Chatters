
Messenger
	var
		name
		winname
		MessageView
			MsgView

	New(mob/chatter/C, Name)
		..()
		if(!Name)
			Name = input("Who would you like to send an instant message to?", "New IM") as text | null
			if(!Name) return
			var/mob/chatter/N = ChatMan.Get(Name)
			if(!N)
				alert(C, "[Name] is not currently online.", "Unable to Locate Chatter.")
				return
			if(N.ignoring(C) & IM_IGNORE)
				alert(C, "[Name] is ignoring instant messages from you.", "Unable to IM chatter.")
				return
			Name = N.name
		name = Name
		winname = "cim_[ckey(name)]"
		winclone(C,"cim",winname)
		winset(C, "[winname]",			"title='[name] - CIM';")
		winset(C, "[winname].name_label","text='[name]';")
		winset(C, "[winname].ignore",	"command='Ignore \"[name]\" \"1\"'")
		winset(C, "[winname].profile",	"command='LookAt \"[name]\"'")
		winset(C, "[winname].show",		"command='Showcode \"[name]\"'")
		winset(C, "[winname].share",		"command='Share \"[name]\"'")
		winset(C, "[winname].invite",	"command='invite \"[name]\"'")
		winset(C, "[winname].join",		"command='Join \"[name]\"'")

		winset(C, "[winname].tag1", "command='InsertTag \"tag1\" \"[name]\"'")
		winset(C, "[winname].tag2", "command='InsertTag \"tag2\" \"[name]\"'")
		winset(C, "[winname].tag3", "command='InsertTag \"tag3\" \"[name]\"'")

		winset(C, "[winname].smiley1", "command='InsertSmiley \"smiley1\" \"[name]\"'")
		winset(C, "[winname].smiley2", "command='InsertSmiley \"smiley2\" \"[name]\"'")
		winset(C, "[winname].smiley3", "command='InsertSmiley \"smiley3\" \"[name]\"'")
		winset(C, "[winname].smiley4", "command='InsertSmiley \"smiley4\" \"[name]\"'")
		winset(C, "[winname].smiley5", "command='InsertSmiley \"smiley5\" \"[name]\"'")
		winset(C, "[winname].smiley6", "command='InsertSmiley \"smiley6\" \"[name]\"'")

		winset(C, "[winname].color1", "command='InsertColor \"color1\" \"[name]\"'")
		winset(C, "[winname].color2", "command='InsertColor \"color2\" \"[name]\"'")
		winset(C, "[winname].color3", "command='InsertColor \"color3\" \"[name]\"'")
		winset(C, "[winname].color4", "command='InsertColor \"color4\" \"[name]\"'")
		winset(C, "[winname].color5", "command='InsertColor \"color5\" \"[name]\"'")
		winset(C, "[winname].color6", "command='InsertColor \"color6\" \"[name]\"'")
		winset(C, "[winname].color7", "command='InsertColor \"color7\" \"[name]\"'")

		winset(C, "[winname].toggle_quickbar", "command='ToggleCIMBar \"[name]\"'")

		winset(C, "[winname].input", "command='IM \"[name]\" \"'")
		winset(C, "[winname].input", "focus=true")

		winset(C, "[winname].output", "style='[TextMan.escapeQuotes(C.default_output_style)]';max-lines='[C.max_output]';")

		if(!C.quickbar)
			C.ToggleCIMBar(name)

		if(!C.msgHandlers)
			C.msgHandlers=new
		C.msgHandlers += ckey(name)
		C.msgHandlers[ckey(name)] = src

	Topic()
		..()

	proc
		Display(mob/chatter/C)
			winshow(C, winname, 1)