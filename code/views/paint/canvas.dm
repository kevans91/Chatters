
turf
	canvas
		icon = './resources/icons/paint/canvas.dmi'
		mouse_opacity = 0


obj
	grid
		name = ""
		icon = './resources/icons/paint/canvas.dmi'
		icon_state = "grid"
		mouse_opacity = 0
		layer = MOB_LAYER


	preview_pixel
		name = "Preview"
		icon = './resources/icons/paint/canvas.dmi'
		icon_state = "pixel"
		var/x_pos, y_pos


	pixel
		icon = './resources/icons/paint/canvas.dmi'
		var/x_pos, y_pos, rgb
		var/obj/preview_pixel/pixel
		var/PaintView/PV
		var/list/neighbors
		mouse_over_pointer = MOUSE_ACTIVE_POINTER

		New(Loc,PaintView/P)
			..()
			if(!P) return
			PV = P


		MouseUp(Loc, control, params)
			var/mob/chatter/M = usr
			if(!M.Painter) return
			switch(M.Painter.current_tool)
				if("select") M.Painter.Select.Up(src, params)
				if("line")   M.Painter.Line.Up(src, params)
				if("rect")   M.Painter.Rect.Up(src, params)
				if("frect")  M.Painter.fRect.Up(src, params)
				if("oval")   M.Painter.Oval.Up(src, params)
				if("foval")  M.Painter.fOval.Up(src, params)

		MouseDrag(over_object,a,b,c,d,params)
			if(!istype(over_object, /obj/pixel)) return
			var/mob/chatter/M = usr
			if(!M.Painter) return
			var/obj/pixel/P = over_object
			switch(M.Painter.current_tool)
				if("select") M.Painter.Select.Drag(P, params)
				if("pencil") M.Painter.Pencil.Drag(P, params)
				if("eraser") M.Painter.Eraser.Drag(P, params)
				if("bucket") M.Painter.Bucket.Drag(P, params)
				if("line")   M.Painter.Line.Drag(P, params)
				if("rect")   M.Painter.Rect.Drag(P, params)
				if("frect")  M.Painter.fRect.Drag(P, params)
				if("oval")   M.Painter.Oval.Drag(P, params)
				if("foval")  M.Painter.fOval.Drag(P, params)

		MouseDown(Loc, control, params)
			var/mob/chatter/M = usr
			if(!M.Painter) return
			switch(M.Painter.current_tool)
				if("select")  M.Painter.Select.Down(src, params)
				if("pencil")  M.Painter.Pencil.Down(src, params)
				if("eraser")  M.Painter.Eraser.Down(src, params)
				if("bucket")  M.Painter.Bucket.Down(src, params)
				if("dropper") M.Painter.Dropper.Down(src, params)
				if("line")    M.Painter.Line.Down(src, params)
				if("swap")    M.Painter.Swap.Down(src, params)
				if("rect")    M.Painter.Rect.Down(src, params)
				if("frect")   M.Painter.fRect.Down(src, params)
				if("oval")    M.Painter.Oval.Down(src, params)
				if("foval")   M.Painter.fOval.Down(src, params)

		proc
			SetColor(color)
				if(rgb == color) return
				rgb = color
				icon = PaintMan.icon_cache[color]
				pixel.icon = icon

