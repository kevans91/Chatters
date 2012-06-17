
GameManager

	proc
		CheckRoll(dice)
			if(!dice) return
			var/D, N, M, S, O, P
			D = findtext(dice, "d")
			if(!D || (D == length(dice))) return
			N = round(max(min(text2num(copytext(dice, 1, D)),10),1))
			M = findtext(dice, "+")
			P = "+"
			if(!M)
				M = findtext(dice, "-")
				P = ""
			S = round(max(min(text2num(copytext(dice, D+1, M)),100),1))
			if(M)
				O = max(min(text2num(copytext(dice, M)),99),-99)
				dice = "[N]d[S][P][O]"
			else dice = "[N]d[S]"
			return list(dice, N, S, O)


		UpdateWho(Channel/Chan)
			if(!Chan || !Chan.players || !Chan.players.len) return
			for(var/mob/chatter/C in Chan.players)

				var/players = 0
				var/idle = 0

				if(!ChatMan.istelnet(C.key))
					for(var/i=1, i<=Chan.players.len, i++)
						var/mob/chatter/c = Chan.players[i]
						if(C.client) winset(C, "games_who.grid", "current-cell=1,[i]")
						var/n = c.name
						if(c==C)
							if(c.afk)
								idle++
								players ++
								if(C.client) winset(C, "games_who.grid", "style='body{color:gray;font-weight:bold;}'")
								c.name += " \[AFK]"
							else
								players ++
								if(C.client) winset(C, "games_who.grid", "style='body{color:[C.game_color];font-weight:bold;}'")
						else
							if(!ChatMan.istelnet(c.key) && c.afk)
								if(C.game_color == c.game_color)
									idle++
									players ++
								if(C.client) winset(C, "games_who.grid", "style='body{color:gray;}'")
								c.name += " \[AFK]"
							else
								if(C.game_color == c.game_color) players ++
								if(C.client) winset(C, "games_who.grid", "style='body{color:[c.game_color];}'")
						C << output(c, "games_who.grid")
						c.name = n
				var/active = players - idle
				if(C.client)
					winset(C, "games.online", "text='[players] Player\s - [active] Active';")
					winset(C, "games_who.grid", "cells=1x[Chan.players.len]")

