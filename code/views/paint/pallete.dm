
turf
	pallete
		name = ""
		icon = './resources/icons/paint/paint.dmi'
		icon_state = "pallete"

	pallete_left
		name = ""
		icon = './resources/icons/paint/paint.dmi'
		icon_state = "pallete_left"

	pallete_right
		name = ""
		icon = './resources/icons/paint/paint.dmi'
		icon_state = "pallete_right"


obj
	colorbox
		icon = './resources/icons/paint/paint.dmi'
		name = ""

		Primary
			icon_state = "primary_frame"

		Secondary
			icon_state = "secondary_frame"

		Switch
			name = "Switch Brushes"
			icon_state = "switch"

			New()
				..()
				pixel_x -= 13
				pixel_y -= 4

			Click(Loc, control, params)
				var/mob/chatter/M = usr, C
				if(M.Painter)
					swapVars(M.Painter.PC.rgb, M.Painter.SC.rgb, C)
					M.Painter.PC.name = M.Painter.PC.rgb
					M.Painter.PC.icon -= "#FFFFFF"
					M.Painter.PC.icon += M.Painter.PC.rgb
					M.Painter.SC.name = M.Painter.SC.rgb
					M.Painter.SC.icon -= "#FFFFFF"
					M.Painter.SC.icon += M.Painter.SC.rgb

	pallete
		icon = './resources/icons/paint/pallete.dmi'
		var/PaintView/PV, rgb
		mouse_over_pointer = MOUSE_HAND_POINTER

		Click(Loc, control, params)
			var/mob/chatter/M = usr
			if(M.Painter) M.Painter.Pallete.Down(src, params)

		DblClick(Loc, control, params)
			var/mob/chatter/M = usr
			if(M.Painter) M.Painter.Pallete.DblDown(src, params)

		proc
			Initialize(PaintView/P, color)
				if(!P || !color) return
				PV = P
				name = color
				icon += color
				rgb = color
				pixel_x += 16
				var/icon/I = new('./resources/icons/paint/canvas.dmi')
				I.Blend(color, ICON_MULTIPLY)
				PaintMan.icon_cache += color
				PaintMan.icon_cache[color] = I


	PrimaryColor
		icon = './resources/icons/paint/pallete.dmi'
		icon_state = "primary"
		var/PaintView/PV, rgb
		mouse_over_pointer = MOUSE_HAND_POINTER

		Click(Loc, control, params)
			var/mob/chatter/M = usr
			if(M.Painter) M.Painter.Primary.Down(params)

		DblClick(Loc, control, params)
			var/mob/chatter/M = usr
			if(M.Painter) M.Painter.Primary.DblDown(params)

		proc
			Initialize(PaintView/P, color)
				if(!P || !color) return
				PV = P
				name = color
				icon += color
				rgb = color
				pixel_x -= 8
				pixel_y += 8
				layer++
				for(var/obj/colorbox/Primary/p in loc)
					p.pixel_x = pixel_x
					p.pixel_y = pixel_y
					p.layer++

	SecondaryColor
		icon = './resources/icons/paint/pallete.dmi'
		icon_state = "secondary"
		var/PaintView/PV, rgb
		mouse_over_pointer = MOUSE_HAND_POINTER

		Click(Loc, control, params)
			var/mob/chatter/M = usr
			if(M.Painter) M.Painter.Secondary.Down(src, params)

		DblClick(Loc, control, params)
			var/mob/chatter/M = usr
			if(M.Painter) M.Painter.Secondary.DblDown(src, params)

		proc
			Initialize(PaintView/P, color)
				if(!P || !color) return
				PV = P
				name = color
				icon += color
				rgb = color
				pixel_x += 6
				pixel_y -= 8
				for(var/obj/colorbox/Secondary/s in loc)
					s.pixel_x = pixel_x
					s.pixel_y = pixel_y
