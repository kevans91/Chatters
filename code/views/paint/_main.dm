
PaintView
	var
		swapmap/Interface
		mob/chatter/owner
		icon/undo_buffer
		icon/redo_buffer
		list
			contents
			grid[CANVASX][CANVASY]

	Del()
		owner = null
		for(var/X in contents)
			for(var/Y in X)
				if(ismob(Y) && Y:key)
					Y:Move()
				else del(Y)
			del(X)
		listClose(contents)
		for(var/X in grid) del(X)
		listClose(grid)
		Interface.Del()
		..()

	proc
		Initialize(mob/chatter/C)
			owner = C
			Interface = SwapMaps_Load("Paint")
			Interface.SetID("[owner.key] - Untitled")
			contents = listOpen(contents)
			contents = Interface.AllTurfs()
			undo_buffer = new('./resources/icons/paint/undo.dmi')
			for(var/turf/T in contents) contents += T.contents
			owner.Painter = new()
			owner.Painter.Initialize(owner, src)

		Display(mob/chatter/C)
			if(!C || !C.client || C.telnet) return
			C.Move(Interface.LoCorner())
			winshow(C, "map", 1)

		recUndo(mob/chatter/C, redo)
			if(!redo)
				redo_buffer = new('./resources/icons/paint/undo.dmi')
				winset(C, "paint.redo", "is-disabled=true")
			var/list/states = icon_states(undo_buffer)
			if(states && states.len)
				if(states.len >= UNDONUM)
					states.Remove("[states[1]]")
			else winset(C, "paint.undo", "is-disabled=false")
			var/icon/I = new('./resources/icons/null.dmi')
			for(var/X=1, X<=CANVASX, X++)
				for(var/Y=1, Y<=CANVASY, Y++)
					var/obj/pixel/P = grid[X][Y]
					I.DrawBox(P.rgb,X,Y)
			var/icon/temp_buffer = new('./resources/icons/paint/undo.dmi')
			if(states && states.len)
				for(var/s=1, s<=states.len, s++)
					var/icon/J = new(undo_buffer, states[s])
					temp_buffer.Insert(J, "[s]")
			temp_buffer.Insert(I, "[states.len+1]")
			undo_buffer = temp_buffer

		recRedo(mob/chatter/C)
			var/list/states = icon_states(undo_buffer)
			var/list/redo_states = icon_states(redo_buffer)
			if(!redo_states || !redo_states.len)
				winset(C, "paint.redo", "is-disabled=false")
			var/icon/I = new('./resources/icons/null.dmi')
			for(var/X=1, X<=CANVASX, X++)
				for(var/Y=1, Y<=CANVASY, Y++)
					var/obj/pixel/P = grid[X][Y]
					I.DrawBox(P.rgb,X,Y)
			var/icon/temp_buffer = new('./resources/icons/paint/undo.dmi')
			if(redo_states && redo_states.len)
				for(var/s=1, s<=redo_states.len, s++)
					var/icon/J = new(redo_buffer, "[redo_states[s]]")
					temp_buffer.Insert(J, "[redo_states[s]]")
			temp_buffer.Insert(I, "[states.len]")
			redo_buffer = temp_buffer

		restoreUndo(mob/chatter/C)
			var/list/states = icon_states(undo_buffer)
			if(!states || !states.len) return
			recRedo(C)
			var/icon/I = new(undo_buffer, "[states.len]")
			var/icon/temp_buffer = new('./resources/icons/paint/undo.dmi')
			states.Remove("[states.len]")
			for(var/X=1, X<=CANVASX, X++)
				for(var/Y=1, Y<=CANVASY, Y++)
					sleep(-1)
					var/color = uppertext(I.GetPixel(X, Y))
					var/obj/pixel/P = grid[X][Y]
					P.SetColor(color)
			if(states && states.len)
				for(var/s=1, s<=states.len, s++)
					var/icon/K = new(undo_buffer, "[states[s]]")
					temp_buffer.Insert(K, "[s]")
				undo_buffer = temp_buffer
			else
				undo_buffer = new('./resources/icons/paint/undo.dmi')
				winset(C, "paint.undo", "is-disabled=true")

		restoreRedo(mob/chatter/C)
			var/list/redo_states = icon_states(redo_buffer)
			if(!redo_states || !redo_states.len) return
			recUndo(C, 1)
			var/icon/temp_buffer = new('./resources/icons/paint/undo.dmi')
			var/icon/I = new(redo_buffer, "[redo_states[redo_states.len]]")
			redo_states.Remove("[redo_states[redo_states.len]]")
			for(var/X=1, X<=CANVASX, X++)
				for(var/Y=1, Y<=CANVASY, Y++)
					sleep(-1)
					var/color = uppertext(I.GetPixel(X, Y))
					var/obj/pixel/P = grid[X][Y]
					P.SetColor(color)
			if(redo_states && redo_states.len)
				for(var/s=1, s<=redo_states.len, s++)
					var/icon/K = new(redo_buffer, "[redo_states[s]]")
					temp_buffer.Insert(K, "[redo_states[s]]")
				redo_buffer = temp_buffer
			else
				redo_buffer = new('./resources/icons/paint/undo.dmi')
				winset(C, "paint.redo", "is-disabled=true")

		Load(mob/chatter/C)
			if(!C || !C.Painter) return
			var/icon/Icon = input(C, "Please select an icon file to load.", "Load Image") as null|icon
			if(isnull(Icon)) return
			var/list/states = icon_states(Icon)
			if(!states || !states.len)
				alert(C, "That icon does not contain any icon states.", "Unable to Load Image")
				return
			var/state
			if(states.len == 1)
				state = states[1]
			else
				state = input("Please select an icon state to load.", "Load State") as null|anything in states
				if(isnull(state)) return
			var/icon/I = new(Icon, state)
			for(var/X=1, X<=CANVASX, X++)
				for(var/Y=1, Y<=CANVASY, Y++)
					sleep(-1)
					var/color = uppertext(I.GetPixel(X, Y))
					if(!color) color = "#C0C0C0"
					if(length(color)>7) color = copytext(color, 1, 8)
					var/obj/pixel/P = grid[X][Y]
					if(!(color in PaintMan.icon_cache))
						var/icon/c = new('./resources/icons/paint/canvas.dmi')
						c.Blend(color, ICON_MULTIPLY)
						PaintMan.icon_cache += color
						PaintMan.icon_cache[color] = c
					P.SetColor(color)


		Save(mob/chatter/C)
			if(!C || !C.Painter) return
			var/icon/I = new('./resources/icons/null.dmi')
			for(var/X=1, X<=CANVASX, X++)
				for(var/Y=1, Y<=CANVASY, Y++)
					var/obj/pixel/P = grid[X][Y]
					if(P.rgb == "#C0C0C0") continue
					I.DrawBox(P.rgb,X,Y)
			C << ftp(I, "untitled.dmi")


