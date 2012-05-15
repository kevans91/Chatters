
ChatterManager

	var
		tmp/list/Dummies

	Topic(href, href_list)
		..()
		var/mob/chatter/Source = Get(url_decode(href_list["source"] || ""))
		//var/mob/chatter/Target = Get(url_decode(href_list["target"] || ""))
		var/index = text2num(href_list["index"])
		if (!istype(Source) || index > Home.showcodes.len) return
		var/showcode_snippet/snippet = Home.showcodes[index]
		switch(href_list["action"])
			if("showcode")
				if (snippet.target && snippet.owner != Source.key && snippet.target != Source.key)
					// This is a private message they are not allowed to view.
					return
				else
					Source << browse(snippet.ReturnHtml(Source, 1), "window=showcode_[snippet.id];display=1;size=800x500;border=1;can_close=1;can_resize=1;titlebar=1")
			if("showtext")
				if (snippet.target && snippet.owner != Source.key && snippet.target != Source.key)
					// This is a private message they are not allowed to view.
					return
				else
					Source << browse(snippet.ReturnHtml(Source), "window=showtext_[snippet.id];display=1;size=800x500;border=1;can_close=1;can_resize=1;titlebar=1")

	proc
		Usher(mob/Temp/T)
			if(!T || !T.client)
				del T
				return

			var/mob/chatter/C = new()

			// Do not call client.Import on telnet users
			if(!istelnet(T.key))
				var/client_file
				client_file = T.client.Import()
				if(client_file == "-1.sav") client_file = null
				if(client_file)
					if(!Load(C, client_file))
							// Out of date or bad savefile, discard.
						T.client.Export()
						C.name = T.name
						C.key = T.key
				else
					C.name = T.name
					C.key = T.key
				var/SetView/SV = new(); SV.Initialize(C); del(SV)
				var/HelpView/HV = new(); HV.Initialize(C); del(SV)
				var/GamesView/GV = new(); GV.Initialize(C); del(SV)
			else
				C.name = T.name
				C.key = T.key

			del(T)


		// Tests if the key is a telnet key eg: Telnet @127.000.000.001
		istelnet(key)
			if(findtext(key, "Telnet @") == 1)
				return 1


		Get(chatter, local)
			if(!length(chatter)) return
			if(!Home || !Home.chatters && NetMan.Status != CONNECTED) return

			if(Home && Home.chatters)
				var first_char = text2ascii(copytext(chatter, 1, 2))
				// If search starts with a number, search IPs.
				if(first_char > 47 && first_char < 58)
					// Exact IP first
					for(var/mob/chatter/C in Home.chatters)
						if(C.client.address == chatter)
							return C

					// Partial IP second
					for(var/mob/chatter/C in Home.chatters)
						if(TextMan.Match(C.client.address, chatter))
							return C

				else
					// Exact key search.
					for(var/mob/chatter/C in Home.chatters)
						if(ckey(C.name) == ckey(chatter)) return C

					// Partial case-sensitive key search
					for(var/mob/chatter/C in Home.chatters)
						if(TextMan.Match(C.key, chatter)) return C

					// Partial non-case-sensitive key search
					for(var/mob/chatter/C in Home.chatters)
						if(TextMan.Match(C.ckey, chatter)) return C

			if(!local && NetMan.Status == CONNECTED)
				if(!NetMan || !NetMan.Chatters || !NetMan.Chatters.len)
					return
				// Exact key search.
				for(var/mob/chatter/C in world)
					if(ckey(C.name) == ckey(chatter)) return C

				// Partial case-sensitive key search
				for(var/mob/chatter/C in world)
					if(TextMan.Match(C.key, chatter)) return C

				// Partial non-case-sensitive key search
				for(var/mob/chatter/C in world)
					if(TextMan.Match(C.ckey, chatter)) return C
				// Exact key search.
				for(var/C in NetMan.Chatters)
					if(ckey(C) == ckey(chatter)) return C

				// Partial case-sensitive key search
				for(var/C in NetMan.Chatters)
					if(TextMan.Match(C, chatter)) return C

				// Partial non-case-sensitive key search
				for(var/C in NetMan.Chatters)
					if(TextMan.Match(ckey(C), chatter)) return C


		Rank(chatter)
			if(Home && chatter)
				var/cKey = ckey(chatter)
				if(cKey in Home.operators)
					var/Op/O = Home.operators[cKey]
					return O.Rank
				return "All"


		ParseFormat(format, variables[], required[])
			if(!format || !variables || !variables.len) return FALSE
			if(required)
				for(var/r in required)
					if(!findtext(format, r)) return FALSE
			var/list/L = new()
			var/temp = format
			for(var/v in variables)
				var/pos = findtext(format, v)
				if(pos) variables[v] = pos
				else variables -= v
			for(var/v = variables.len, v >= 1, v--)
				for(var/i = 1, i < v, i++)
					if(variables[variables[i]] > variables[variables[i+1]])
						variables.Swap( i, i+1)
					else if(variables[variables[i]] == variables[variables[i+1]])
						variables -= variables[i+1]
					if(v > variables.len) break
			for(var/v in variables)
				var/pos = findtext(temp, v)
				if(pos > 1)
					L += copytext(temp, 1, pos)
				L += v
				temp = copytext(temp, pos+length(v))
			if(length(temp))
				L += temp
			return L

		Load(mob/chatter/C, client_file)
			var/savefile/F = new(client_file)
			var/version
			F["version"] >> version

			if(version == "0.1.5" && ("CRYPTO" in F.dir))
				var/crypto
				F["CRYPTO"] >> crypto
				crypto = RC5_Decrypt(crypto, md5(world.hub_password))
				for(var/i = 1; i <= length(crypto); ++i)
					if(text2ascii(crypto, i) < 32) return FALSE
				F.dir -= "CRYPTO"
				F.ImportText("/",  crypto)
				C.Read(F)
						// Save an updated savefile.
				Save(C)
				return TRUE
			else if(version == savefile_version)
				C.Read(F)
				return TRUE
			else
				return FALSE

		Save(mob/chatter/C)
			var/savefile/S = new()
			C.Write(S)
			S["version"] << savefile_version
			sleep(5)
			C.client.Export(S)


		EditSave(var/save)
			if(!save) return
			var/savefile/F = new(save)
			var/text = F.ExportText("/")
			return text
