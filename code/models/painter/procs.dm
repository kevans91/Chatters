
Painter
	proc
		Initialize(mob/chatter/owner, PaintView/PV)
			if(!owner) return
			if(!(type in typesof(type)-type))
				Owner = owner
				Paint = PV
				Pallete = new(src)
				Primary = new(src)
				Secondary = new(src)
				var/i=1
				for(var/obj/window_button/B in Paint.contents) B.Initialize(Paint)
				for(var/obj/pallete/P in Paint.contents)
					P.Initialize(Paint, pallete[i++])
				for(var/obj/PrimaryColor/P in Paint.contents) PC = P
				for(var/obj/SecondaryColor/S in Paint.contents) SC = S
				PC.Initialize(Paint, "#000000")
				SC.Initialize(Paint, "#FFFFFF")
				for(var/obj/window_button/tool/pencil/P in Paint.contents) P.Update(1)
				var/list/States = list("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P")
				var/turf/loCorner = Paint.Interface.LoCorner()
				var/turf/start = locate(loCorner.x+2,loCorner.y+2,loCorner.z)
				var/turf/end   = locate(loCorner.x+9,loCorner.y+9,loCorner.z)
				for(var/turf/canvas/C in block(start,end))
					for(var/state in States)
						var/obj/pixel/p = new(C, Paint)
						var/obj/preview_pixel/pp = new(locate(loCorner.x+11,loCorner.y+1,loCorner.z))
						p.icon_state = state
						p.rgb = "#FFFFFF"
						switch(state)
							if("A"){p.x_pos=(C.x-3)*4+1;p.y_pos=(C.y-3)*4+4}
							if("B"){p.x_pos=(C.x-3)*4+2;p.y_pos=(C.y-3)*4+4}
							if("C"){p.x_pos=(C.x-3)*4+3;p.y_pos=(C.y-3)*4+4}
							if("D"){p.x_pos=(C.x-3)*4+4;p.y_pos=(C.y-3)*4+4}
							if("E"){p.x_pos=(C.x-3)*4+1;p.y_pos=(C.y-3)*4+3}
							if("F"){p.x_pos=(C.x-3)*4+2;p.y_pos=(C.y-3)*4+3}
							if("G"){p.x_pos=(C.x-3)*4+3;p.y_pos=(C.y-3)*4+3}
							if("H"){p.x_pos=(C.x-3)*4+4;p.y_pos=(C.y-3)*4+3}
							if("I"){p.x_pos=(C.x-3)*4+1;p.y_pos=(C.y-3)*4+2}
							if("J"){p.x_pos=(C.x-3)*4+2;p.y_pos=(C.y-3)*4+2}
							if("K"){p.x_pos=(C.x-3)*4+3;p.y_pos=(C.y-3)*4+2}
							if("L"){p.x_pos=(C.x-3)*4+4;p.y_pos=(C.y-3)*4+2}
							if("M"){p.x_pos=(C.x-3)*4+1;p.y_pos=(C.y-3)*4+1}
							if("N"){p.x_pos=(C.x-3)*4+2;p.y_pos=(C.y-3)*4+1}
							if("O"){p.x_pos=(C.x-3)*4+3;p.y_pos=(C.y-3)*4+1}
							if("P"){p.x_pos=(C.x-3)*4+4;p.y_pos=(C.y-3)*4+1}
						p.name = "[p.x_pos],[p.y_pos]"
						Paint.grid[p.x_pos][p.y_pos] = p
						pp.pixel_x = p.x_pos-1
						pp.pixel_y = p.y_pos-1
						p.pixel = pp
						Paint.contents += p
				for(var/obj/pixel/P in Paint.contents)
					P.neighbors = listOpen(P.neighbors)
					if(P.y_pos+1 <= CANVASY)
						var/obj/pixel/p = Paint.grid[P.x_pos][P.y_pos+1]
						P.neighbors += p
					else if(P.y_pos-1 >= 1)
						var/obj/pixel/p = Paint.grid[P.x_pos][P.y_pos-1]
						P.neighbors += p
					if(P.x_pos+1 <= CANVASX)
						var/obj/pixel/p = Paint.grid[P.x_pos+1][P.y_pos]
						P.neighbors += p
						if(P.y_pos+1 <= CANVASY)
							p = Paint.grid[P.x_pos+1][P.y_pos+1]
							P.neighbors += p
						else if(P.y_pos-1 >= 1)
							p = Paint.grid[P.x_pos+1][P.y_pos-1]
							P.neighbors += p
					else if(P.x_pos-1 >= 1)
						var/obj/pixel/p = Paint.grid[P.x_pos-1][P.y_pos]
						P.neighbors += p
						if(P.y_pos+1 <= CANVASY)
							p = Paint.grid[P.x_pos-1][P.y_pos+1]
							P.neighbors += p
						else if(P.y_pos-1 >= 1)
							p = Paint.grid[P.x_pos-1][P.y_pos-1]
							P.neighbors += p
				Paint.Display(Owner)

		selectMerge()
			var/list/L = list(\
				"A" = "0,24", "B" = "8,24", "C" = "16,24", "D" = "24,24",
				"E" = "0,16", "F" = "8,16", "G" = "16,16", "H" = "24,16",
				"I" = "0,8" , "J" = "8,8" , "K" = "16,8" , "L" = "24,8",
				"M" = "0,0" , "N" = "8,0" , "O" = "16,0" , "P" = "24,0")
			for(var/obj/pixel/P in current_select)
				var/links = 0
				for(var/direction in list(NORTH,SOUTH,EAST,WEST))
					if(direction == NORTH)
						if(P.y_pos+1 <= CANVASY)
							var/obj/pixel/p = Paint.grid[P.x_pos][P.y_pos+1]
							if(p in current_select) links |= NORTH
					if(direction == SOUTH)
						if(P.y_pos-1 >= 1)
							var/obj/pixel/p = Paint.grid[P.x_pos][P.y_pos-1]
							if(p in current_select) links |= SOUTH
					if(direction == EAST)
						if(P.x_pos+1 <= CANVASX)
							var/obj/pixel/p = Paint.grid[P.x_pos+1][P.y_pos]
							if(p in current_select) links |= EAST
					if(direction == WEST)
						if(P.x_pos-1 >= 1)
							var/obj/pixel/p = Paint.grid[P.x_pos-1][P.y_pos]
							if(p in current_select) links |= WEST
				var/image/I = new('./resources/icons/paint/select.dmi',P,"[links]",FLY_LAYER)
				var/list/O = explode(L[P.icon_state], ",")
				I.pixel_x = text2num(O[1])
				I.pixel_y = text2num(O[2])
				O.len = null
				listClose(O)
				P.overlays += I
			L.len = null
			listClose(L)

		flood(x, y, old, fill)
			if ((x < 1) || (x > CANVASX)) return
			if ((y < 1) || (y > CANVASY)) return
			if (old == fill) return
			var/obj/pixel/P = Paint.grid[x][y]
			P.SetColor(fill)
			spawn()
				fillEast(x+1, y, fill, old)
				fillSouth(x, y+1, fill, old)
				fillWest(x-1, y, fill, old)
				fillNorth(x, y-1, fill, old)

		fillEast(x, y, fill, old)
			if (x > CANVASX) return
			var/obj/pixel/P = Paint.grid[x][y]
			if (P.rgb == old)
				P.SetColor(fill)
				spawn()
					fillEast(x+1, y, fill, old)
					fillSouth(x, y+1, fill, old)
					fillNorth(x, y-1, fill, old)

		fillSouth(x, y, fill, old)
			if (y > CANVASY) return
			var/obj/pixel/P = Paint.grid[x][y]
			if (P.rgb == old)
				P.SetColor(fill)
				spawn()
					fillEast(x+1, y, fill, old)
					fillSouth(x, y+1, fill, old)
					fillWest(x-1, y, fill, old)

		fillWest(x, y, fill, old)
			if (x < 1) return
			var/obj/pixel/P = Paint.grid[x][y]
			if (P.rgb == old)
				P.SetColor(fill)
				spawn()
					fillSouth(x, y+1, fill, old)
					fillWest(x-1, y, fill, old)
					fillNorth(x, y-1, fill, old)

		fillNorth(x, y, fill, old)
			if (y < 1) return
			var/obj/pixel/P = Paint.grid[x][y]
			if (P.rgb == old)
				P.SetColor(fill)
				spawn()
					fillEast(x+1, y, fill, old)
					fillWest(x-1, y, fill, old)
					fillNorth(x, y-1, fill, old)

		fillRect(mode, color)
			var/C
			var/beginX = startX, beginY = startY
			var/endX = (prevX || startX), endY = (prevY || startY)
			if(shift)
				var/dx = abs(endX - startX)
				var/dy = abs(endY - startY)
				if(dx>dy)
					if(startY > endY) { endY += dy; endY -= dx }
					else { endY -= dy; endY += dx }
				else
					if(startX > endX) { endX += dx; endX -= dy }
					else { endX -= dx; endX += dy }
				if(endX>32) endX -= (endX-32)<<1
				if(endY>32) endY -= (endY-32)<<1
			if(beginX > endX) {swapVars(beginX,endX,C)}
			if(beginY > endY) {swapVars(beginY,endY,C)}
			for(var/X=beginX, X<=endX, X++)
				for(var/Y=beginY, Y<=endY, Y++)
					var/obj/pixel/P = Paint.grid[X][Y]
					switch(mode)
						if("clear") P.overlays.len = null
						if("set") {P.SetColor(color); P.overlays.len = null}
						if("over") P.overlays += image(PaintMan.icon_cache[color],P,P.icon_state)
						if("select") current_select += P

		GetColorBox(params)
			if(findtext(params, ";left=1")) return PC
			else return SC

