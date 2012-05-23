
EventManager
	var
		const
			CH_LPAREN = 40
			CH_RPAREN = 42
			CH_QUOTES = 34
			CH_SPACE = 32
			CH_BACKSLSH = 92
	proc
		Parse(mob/chatter/C, event)
			var/cmd = ""
			var/cmd_end = 0
			for(var/i = 1; i <= length(event); ++i)
				var/ch = text2ascii(event, i)
				if(ch == CH_LPAREN)
					cmd_end = i
					break
				else if(ch == CH_QUOTES)
					cmd_end = i
					break
				else if(ch == CH_SPACE)
					cmd_end = i
					break
				else
					cmd += ascii2text(ch)

			var
				text = 0
				endtext = 0

			for(var/i = cmd_end + 1; i <= length(event); ++i)
				var/ch = text2ascii(event, i)
				if(!text && ch != CH_SPACE && ch != CH_QUOTES)
					text = i
				else if(!text && ch == CH_QUOTES)
					text = i + 1
				else if(text && ch == CH_QUOTES)
					if(text2ascii(event, i - 1) != CH_BACKSLSH)
						endtext = i
						break
			if(!endtext) return
			var/params = copytext(event, text, endtext)
			for(var/v in C.verbs)
				if(ckey(cmd) == ckey(v:name))
					call(C, v:name)(params)