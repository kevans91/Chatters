
mob

	Temp
		Login()
			..()

			var/timer = world.timeofday
			while(!client)
				if(world.timeofday > timer+180) del(src)
				sleep(-1)

			// Initialize telnet by outputting a message to them.
			if(ChatMan.istelnet(key))
				if(!Home)
					src << "\white Please wait while your host configures the channel..."
					while(!Home) sleep(10)
				if(findtext(name, "Telnet @"))
					name = copytext(name, 9)
					var/a_pos = findtext(name, ".", 1)
					var/b_pos = findtext(name, ".", a_pos+1)
					var/c_pos = findtext(name, ".", b_pos+1)
					name = "[text2num(copytext(name, 1, a_pos))].[text2num(copytext(name, a_pos+1, b_pos))].[text2num(copytext(name, b_pos+1, c_pos))].[text2num(copytext(name, c_pos+1))]"
				if(ckey(name) in Home.banned) del(src)
				if(Home.telnet_pass)
					src << "\white This channel requires authorization for telnet clients."
					var/pass, attempts = (Home.telnet_attempts || -1)
					while(!pass)
						pass = input(src, "Please enter the telnet password.")
						if(!pass)
							src << ""
							src << "\red No password supplied. Closing connection...\..."
							sleep(5)
							del(src)
						if(pass != Home.telnet_pass)
							if(!--attempts)
								src << ""
								src << "\red Maximum attemtps reached. Closing connection...\..."
								sleep(5)
								del(src)
							src << ""
							src << "\red Access Denied! Please try again."
							sleep(3)
							pass = null
					src << ""
					src << "\green Access Granted!"
					src << ""
					sleep(5)

			ChatMan.Usher(src)

		verb // temp fix for interface initialization
			InsertTag(var/X as text|null)
			InsertColor(var/X as text|null)
			SetGender(var/X as text|null)