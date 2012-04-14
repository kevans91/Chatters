
MessageHandler
	var
		mob/chatter/owner

	New(mob/chatter/C)
		owner = C
		..()

	proc
		GetMsg(mob/chatter/From, msg, clean)
			if(!clean) msg = TextMan.Sanitize(msg)

			var/fmsg = msg
			var/omsg = msg

			if(!(ckey(From.name) in owner.msgHandlers))
				var/Messenger/im = new(owner, From.name)
				im.Display(owner)

			winset(owner, "cim_[ckey(From.name)]", "is-visible=true;")
			if(owner.filter) omsg = TextMan.FilterChat(omsg, owner)
			if(owner.filter) fmsg = TextMan.FilterChat(fmsg, From)

			if(owner.show_smileys) omsg = TextMan.ParseSmileys(omsg)
			if(From.show_smileys) fmsg = TextMan.ParseSmileys(fmsg)
			omsg = TextMan.ParseLinks(omsg)
			fmsg = TextMan.ParseLinks(fmsg)

			var/show_oimages = owner.show_images
			if(show_oimages) show_oimages = !(owner.ignoring(From) & IMAGES_IGNORE)
			var/show_fimages = From.show_images
			if(show_fimages) show_fimages = !(From.ignoring(owner) & IMAGES_IGNORE)

			omsg = TextMan.ParseTags(omsg, owner.show_colors, owner.show_highlight,show_oimages)
			fmsg = TextMan.ParseTags(fmsg, From.show_colors, From.show_highlight,show_fimages)

			if(From != owner)
				From << output(From.ParseMsg(From, fmsg, From.say_format), "cim_[ckey(owner.name)].output")
				if(From.im_sounds) From << sound(From.snt_msg_snd,,,,From.im_volume)
			owner << output(owner.ParseMsg(From, omsg, owner.say_format), "cim_[ckey(From.name)].output")
			if(owner.im_sounds) owner << sound(owner.got_msg_snd,,,,owner.im_volume)
