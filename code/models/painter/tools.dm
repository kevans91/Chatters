
Tools
	var/obj/window_button/Button
	var/Painter/Painter

	proc
		Up(obj/pixel/Ref, params)

		Drag(obj/pixel/Ref, params)

		Down(obj/pixel/Ref, params)

	select
		Up(obj/pixel/Ref, params)
			for(var/obj/pixel/P in Painter.current_select)
				P.overlays.len = null
			Painter.startX = null
			Painter.startY = null
			Painter.prevX = null
			Painter.prevY = null

		Drag(obj/pixel/Ref, params)
			Painter.fillRect("clear")
			Painter.prevX = Ref.x_pos
			Painter.prevY = Ref.y_pos
			Painter.current_select.len = null
			Painter.fillRect("select")
			Painter.selectMerge()

		Down(obj/pixel/Ref, params)
			Painter.startX = Ref.x_pos
			Painter.startY = Ref.y_pos
			Painter.prevX = Painter.startX
			Painter.prevY = Painter.startY
			Painter.current_select = listOpen(Painter.current_select)
			Painter.current_select += Ref
			Painter.selectMerge()

	arrow

	pencil
		Drag(obj/pixel/Ref, params)
			Painter.Paint.recUndo(Painter.Owner)
			var/obj/ColorBox = Painter.GetColorBox(params)
			Ref.SetColor(ColorBox.name)
			var/obj/pixel/P = Painter.Paint.grid[Painter.prevX][Painter.prevY]
			if(!(P in Ref.neighbors))
				var/L[] = line(Painter.prevX, Painter.prevY, Ref.x_pos, Ref.y_pos)
				for(var/n=1, n<L.len, n+=2)
					var/X = L[n]
					var/Y = L[n+1]
					var/obj/pixel/p = Painter.Paint.grid[X][Y]
					p.SetColor(ColorBox.name)
					p.overlays.len = null
			Painter.prevX = Ref.x_pos
			Painter.prevY = Ref.y_pos

		Down(obj/pixel/Ref, params)
			Painter.Paint.recUndo(Painter.Owner)
			var/obj/ColorBox = Painter.GetColorBox(params)
			Ref.SetColor(ColorBox.name)
			Painter.prevX = Ref.x_pos
			Painter.prevY = Ref.y_pos

	eraser
		Drag(obj/pixel/Ref, params)
			Painter.Paint.recUndo(Painter.Owner)
			if(findtext(params, ";right=1"))
				if(Ref.rgb == Painter.PC.name)
					Ref.SetColor(Painter.SC.name)
					var/obj/pixel/P = Painter.Paint.grid[Painter.prevX][Painter.prevY]
					if(!(P in Ref.neighbors))
						var/L[] = line(Painter.prevX, Painter.prevY, Ref.x_pos, Ref.y_pos)
						for(var/n=1, n<L.len, n+=2)
							var/X = L[n]
							var/Y = L[n+1]
							var/obj/pixel/p = Painter.Paint.grid[X][Y]
							if(p.rgb == Painter.PC.name)
								p.SetColor(Painter.SC.name)
								p.overlays.len = null
			else
				Ref.SetColor(Painter.SC.name)
				var/obj/pixel/P = Painter.Paint.grid[Painter.prevX][Painter.prevY]
				if(!(P in Ref.neighbors))
					var/L[] = line(Painter.prevX, Painter.prevY, Ref.x_pos, Ref.y_pos)
					for(var/n=1, n<L.len, n+=2)
						var/X = L[n]
						var/Y = L[n+1]
						var/obj/pixel/p = Painter.Paint.grid[X][Y]
						p.SetColor(Painter.SC.name)
						p.overlays.len = null
			Painter.prevX = Ref.x_pos
			Painter.prevY = Ref.y_pos

		Down(obj/pixel/Ref, params)
			Painter.Paint.recUndo(Painter.Owner)
			if(findtext(params, ";right=1") && (Ref.rgb != Painter.PC.name))
				Painter.prevX = Ref.x_pos
				Painter.prevY = Ref.y_pos
				return
			Ref.SetColor(Painter.SC.name)
			Painter.prevX = Ref.x_pos
			Painter.prevY = Ref.y_pos

	bucket
		Down(obj/pixel/Ref, params)
			Painter.Paint.recUndo(Painter.Owner)
			var/obj/ColorBox = Painter.GetColorBox(params)
			Painter.flood(Ref.x_pos, Ref.y_pos, Ref.rgb, ColorBox.name)

		Drag(obj/pixel/Ref, params)
			Painter.Paint.recUndo(Painter.Owner)
			var/obj/ColorBox = Painter.GetColorBox(params)
			Painter.flood(Ref.x_pos, Ref.y_pos, Ref.rgb, ColorBox.name)

	dropper
		Down(obj/pixel/Ref, params)
			var/obj/ColorBox = Painter.GetColorBox(params)
			ColorBox.name = Ref.rgb
			ColorBox:rgb = Ref.rgb
			ColorBox.icon -= "#FFFFFF"
			ColorBox.icon += Ref.rgb
			Painter.current_tool = Painter.previous_tool
			Painter.previous_tool = "dropper"
			for(var/obj/window_button/tool/T in Painter.Paint.contents)
				if(T.icon_state == Painter.current_tool) T.Update(1)
			Button.Update(0)

	swap
		Down(obj/pixel/Ref, params)
			if(!Painter.old_color)
				Painter.old_color = Ref.rgb
			else
				Painter.Paint.recUndo(Painter.Owner)
				Painter.new_color = Ref.rgb
				for(var/obj/pixel/P in Painter.Paint.contents)
					if(P.rgb == Painter.old_color)
						P.SetColor(Painter.new_color)
				Painter.old_color = null

	line
		Up(obj/pixel/Ref, params)
			Painter.Paint.recUndo(Painter.Owner)
			Painter.current_line = listOpen(Painter.current_line)
			if(Painter.current_line.len)
				var/obj/ColorBox = Painter.GetColorBox(params)
				for(var/n=1, n<Painter.current_line.len, n+=2)
					var/X = Painter.current_line[n]
					var/Y = Painter.current_line[n+1]
					var/obj/pixel/P = Painter.Paint.grid[X][Y]
					P.SetColor(ColorBox.name)
					P.overlays.len = null
				Painter.current_line = null
				Painter.startX = null
				Painter.startY = null
				Painter.shift = 0

		Drag(obj/pixel/Ref, params)
			if(Painter.shift && !findtext(params, ";shift=1"))
				Painter.shift = 0
			else if(findtext(params, ";shift=1"))
				Painter.shift = 1
			var/obj/ColorBox = Painter.GetColorBox(params)
			Painter.current_line = listOpen(Painter.current_line)
			var/endX = Ref.x_pos
			var/endY = Ref.y_pos
			var/obj/pixel/P
			for(var/n=1, n<Painter.current_line.len, n+=2)
				var/X = Painter.current_line[n]
				var/Y = Painter.current_line[n+1]
				P = Painter.Paint.grid[X][Y]
				P.overlays.len = null
			if(Painter.shift)
				var/dx = abs(endX - Painter.startX)
				var/dy = abs(endY - Painter.startY)
				if(dx>dy)
					if(Painter.startY > endY) { endY += dy; endY -= dx }
					else { endY -= dy; endY += dx }
				else
					if(Painter.startX > endX) { endX += dx; endX -= dy }
					else { endX -= dx; endX += dy }
				if(endX>CANVASX) endX -= (endX-CANVASX)<<1
				if(endY>CANVASY) endY -= (endY-CANVASY)<<1
				if(endX<1) endX += (1-endX)<<1
				if(endY<1) endY += (1-endY)<<1
			Painter.current_line = line(Painter.startX, Painter.startY, endX, endY)
			for(var/n=1, n<Painter.current_line.len, n+=2)
				var/X = Painter.current_line[n]
				var/Y = Painter.current_line[n+1]
				P = Painter.Paint.grid[X][Y]
				P.overlays += image(PaintMan.icon_cache[ColorBox:rgb],P,P.icon_state)

		Down(obj/pixel/Ref, params)
			if(findtext(params, ";shift=1"))
				Painter.shift = 1
			var/obj/ColorBox = Painter.GetColorBox(params)
			Painter.current_line = list(Ref.x_pos, Ref.y_pos)
			Painter.startX = Ref.x_pos
			Painter.startY = Ref.y_pos
			Ref.overlays += image(PaintMan.icon_cache[ColorBox:rgb],Ref,Ref.icon_state)

	rect
		Up(obj/pixel/Ref, params)
			Painter.Paint.recUndo(Painter.Owner)
			Painter.current_rect = listOpen(Painter.current_rect)
			if(Painter.current_rect.len)
				var/obj/ColorBox = Painter.GetColorBox(params)
				for(var/n=1, n<Painter.current_rect.len, n+=2)
					var/X = Painter.current_rect[n]
					var/Y = Painter.current_rect[n+1]
					var/obj/pixel/P = Painter.Paint.grid[X][Y]
					P.SetColor(ColorBox.name)
					P.overlays.len = null
				Painter.current_rect = null
				Painter.startX = null
				Painter.startY = null
				Painter.shift = 0

		Drag(obj/pixel/Ref, params)
			if(Painter.shift && !findtext(params, ";shift=1"))
				Painter.shift = 0
			else if(findtext(params, ";shift=1"))
				Painter.shift = 1
			var/obj/ColorBox = Painter.GetColorBox(params)
			Painter.current_rect = listOpen(Painter.current_rect)
			var/endX = Ref.x_pos
			var/endY = Ref.y_pos
			var/obj/pixel/P
			for(var/n=1, n<Painter.current_rect.len, n+=2)
				var/X = Painter.current_rect[n]
				var/Y = Painter.current_rect[n+1]
				P = Painter.Paint.grid[X][Y]
				P.overlays.len = null
			if(Painter.shift)
				var/dx = abs(endX - Painter.startX)
				var/dy = abs(endY - Painter.startY)
				if(dx>dy)
					if(Painter.startY > endY) { endY += dy; endY -= dx }
					else { endY -= dy; endY += dx }
				else
					if(Painter.startX > endX) { endX += dx; endX -= dy }
					else { endX -= dx; endX += dy }
				if(endX>CANVASX) endX -= (endX-CANVASX)<<1
				if(endY>CANVASY) endY -= (endY-CANVASY)<<1
			Painter.current_rect =  line(Painter.startX, Painter.startY, Painter.startX, endY)
			Painter.current_rect += line(Painter.startX, Painter.startY, endX, Painter.startY)
			Painter.current_rect += line(endX, endY, endX, Painter.startY)
			Painter.current_rect += line(endX, endY, Painter.startX, endY)
			for(var/n=1, n<Painter.current_rect.len, n+=2)
				var/X = Painter.current_rect[n]
				var/Y = Painter.current_rect[n+1]
				P = Painter.Paint.grid[X][Y]
				P.overlays += image(PaintMan.icon_cache[ColorBox:rgb],P,P.icon_state)

		Down(obj/pixel/Ref, params)
			if(findtext(params, ";shift=1"))
				Painter.shift = 1
			var/obj/ColorBox = Painter.GetColorBox(params)
			Painter.current_rect = list(Ref.x_pos, Ref.y_pos)
			Painter.startX = Ref.x_pos
			Painter.startY = Ref.y_pos
			Ref.overlays += image(PaintMan.icon_cache[ColorBox:rgb],Ref,Ref.icon_state)

	frect
		Up(obj/pixel/Ref, params)
			Painter.Paint.recUndo(Painter.Owner)
			var/obj/ColorBox = Painter.GetColorBox(params)
			Painter.fillRect("set", ColorBox.name)
			Painter.startX = null
			Painter.startY = null
			Painter.prevX = null
			Painter.prevY = null
			Painter.shift = 0

		Drag(obj/pixel/Ref, params)
			Painter.fillRect("clear")
			if(Painter.shift && !findtext(params, ";shift=1"))
				Painter.shift = 0
			else if(findtext(params, ";shift=1"))
				Painter.shift = 1
			var/obj/ColorBox = Painter.GetColorBox(params)
			Painter.prevX = Ref.x_pos
			Painter.prevY = Ref.y_pos
			Painter.fillRect("over", ColorBox.name)

		Down(obj/pixel/Ref, params)
			if(findtext(params, ";shift=1"))
				Painter.shift = 1
			var/obj/ColorBox = Painter.GetColorBox(params)
			Painter.current_rect = list(Ref.x_pos, Ref.y_pos)
			Painter.startX = Ref.x_pos
			Painter.startY = Ref.y_pos
			Ref.overlays += image(PaintMan.icon_cache[ColorBox:rgb],Ref,Ref.icon_state)

	oval
		Up(obj/pixel/Ref, params)
			Painter.Paint.recUndo(Painter.Owner)
			Painter.current_oval = listOpen(Painter.current_oval)
			if(Painter.current_oval.len)
				var/obj/ColorBox = Painter.GetColorBox(params)
				for(var/n=1, n<Painter.current_oval.len, n+=2)
					var/X = Painter.current_oval[n]
					var/Y = Painter.current_oval[n+1]
					var/obj/pixel/P = Painter.Paint.grid[X][Y]
					P.SetColor(ColorBox.name)
					P.overlays.len = null
				Painter.current_oval = null
				Painter.startX = null
				Painter.startY = null
				Painter.shift = 0

		Drag(obj/pixel/Ref, params)
			if(Painter.shift && !findtext(params, ";shift=1"))
				Painter.shift = 0
			else if(findtext(params, ";shift=1"))
				Painter.shift = 1
			var/obj/ColorBox = Painter.GetColorBox(params)
			Painter.current_oval = listOpen(Painter.current_oval)
			var/endX = Ref.x_pos
			var/endY = Ref.y_pos
			var/obj/pixel/P
			for(var/n=1, n<Painter.current_oval.len, n+=2)
				var/X = Painter.current_oval[n]
				var/Y = Painter.current_oval[n+1]
				P = Painter.Paint.grid[X][Y]
				P.overlays.len = null
			if(Painter.shift)
				var/dx = abs(endX - Painter.startX)
				var/dy = abs(endY - Painter.startY)
				if(dx>dy)
					if(Painter.startY > endY) { endY += dy; endY -= dx }
					else { endY -= dy; endY += dx }
				else
					if(Painter.startX > endX) { endX += dx; endX -= dy }
					else { endX -= dx; endX += dy }
				if(endX>CANVASX) endX -= (endX-CANVASX)<<1
				if(endY>CANVASY) endY -= (endY-CANVASY)<<1
			Painter.current_oval =  ellipse(Painter.startX, Painter.startY, endX, endY)
			for(var/n=1, n<Painter.current_oval.len, n+=2)
				var/X = Painter.current_oval[n]
				var/Y = Painter.current_oval[n+1]
				P = Painter.Paint.grid[X][Y]
				P.overlays += image(PaintMan.icon_cache[ColorBox:rgb],P,P.icon_state)

		Down(obj/pixel/Ref, params)
			if(findtext(params, ";shift=1"))
				Painter.shift = 1
			Painter.current_oval = new()
			Painter.startX = Ref.x_pos
			Painter.startY = Ref.y_pos

	foval
		Up(obj/pixel/Ref, params)
			Painter.Paint.recUndo(Painter.Owner)
			Painter.current_oval = listOpen(Painter.current_oval)
			if(Painter.current_oval.len)
				var/obj/ColorBox = Painter.GetColorBox(params)
				for(var/n=1, n<Painter.current_oval.len, n+=2)
					var/X = Painter.current_oval[n]
					var/Y = Painter.current_oval[n+1]
					var/obj/pixel/P = Painter.Paint.grid[X][Y]
					P.SetColor(ColorBox.name)
					P.overlays.len = null
				Painter.current_oval = null
				Painter.startX = null
				Painter.startY = null
				Painter.shift = 0

		Drag(obj/pixel/Ref, params)
			if(Painter.shift && !findtext(params, ";shift=1"))
				Painter.shift = 0
			else if(findtext(params, ";shift=1"))
				Painter.shift = 1
			var/obj/ColorBox = Painter.GetColorBox(params)
			Painter.current_oval = listOpen(Painter.current_oval)
			var/endX = Ref.x_pos
			var/endY = Ref.y_pos
			var/obj/pixel/P
			for(var/n=1, n<Painter.current_oval.len, n+=2)
				var/X = Painter.current_oval[n]
				var/Y = Painter.current_oval[n+1]
				P = Painter.Paint.grid[X][Y]
				P.overlays.len = null
			if(Painter.shift)
				var/dx = abs(endX - Painter.startX)
				var/dy = abs(endY - Painter.startY)
				if(dx>dy)
					if(Painter.startY > endY) { endY += dy; endY -= dx }
					else { endY -= dy; endY += dx }
				else
					if(Painter.startX > endX) { endX += dx; endX -= dy }
					else { endX -= dx; endX += dy }
				if(endX>CANVASX) endX -= (endX-CANVASX)<<1
				if(endY>CANVASY) endY -= (endY-CANVASY)<<1
			Painter.current_oval =  ellipse(Painter.startX, Painter.startY, endX, endY, 1)
			for(var/n=1, n<Painter.current_oval.len, n+=2)
				var/X = Painter.current_oval[n]
				var/Y = Painter.current_oval[n+1]
				P = Painter.Paint.grid[X][Y]
				P.overlays += image(PaintMan.icon_cache[ColorBox:rgb],P,P.icon_state)

		Down(obj/pixel/Ref, params)
			if(findtext(params, ";shift=1"))
				Painter.shift = 1
			Painter.current_oval = new()
			Painter.startX = Ref.x_pos
			Painter.startY = Ref.y_pos