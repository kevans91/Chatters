
Pallete
	var/Painter/Painter

	New(Painter/P)
		if(!P) return
		..()
		Painter = P

	proc
		Down(obj/pallete/Ref, params)
			var/obj/ColorBox = Painter.GetColorBox(params)
			if(Painter.current_tool == "dropper")
				ColorBox.name = Ref.rgb
				ColorBox:rgb = Ref.rgb
				ColorBox.icon -= "#FFFFFF"
				ColorBox.icon += Ref.rgb
				if(Painter.current_tool == "dropper")
					Painter.current_tool = Painter.previous_tool
					Painter.previous_tool = "dropper"
					for(var/obj/window_button/tool/T in Painter.Paint.contents)
						if(T.icon_state == Painter.current_tool) T.Update(1)
					Painter.Dropper.Button.Update(0)
			else if(Painter.current_tool == "swap")
				if(!Painter.old_color)
					Painter.old_color = Ref.rgb
				else
					Painter.new_color = Ref.rgb
					for(var/obj/pixel/P in Painter.Paint.contents)
						if(P.rgb == Painter.old_color)
							P.name = Painter.new_color
							P.rgb = Painter.new_color
							P.icon = PaintMan.icon_cache[Painter.new_color]
							P.pixel.icon = P.icon
					Painter.old_color = null
			else
				ColorBox.icon -= ColorBox.name
				ColorBox.icon += Ref.name
				ColorBox.name = Ref.name
				ColorBox:rgb = Ref.rgb

		DblDown(obj/pallete/Ref, params)
			var/mob/chatter/M = Painter.Owner
			Painter.Current = Ref
			var/left = findtext(params, ";left=1")
			if(left) M.CV.Display("primary")
			else M.CV.Display("secondary")

PrimaryColor
	var/obj/window_button/Button
	var/Painter/Painter

	New(Painter/P)
		if(!P) return
		..()
		Painter = P
		Button = Painter.PC

	proc
		Down(params)
			if(Painter.current_tool == "swap")
				if(!Painter.old_color)
					Painter.old_color = Painter.PC.rgb
				else
					Painter.new_color = Painter.PC.rgb
					for(var/obj/pixel/P in Painter.Paint.contents)
						if(P.rgb == Painter.old_color)
							P.name = Painter.new_color
							P.rgb = Painter.new_color
							P.icon = PaintMan.icon_cache[Painter.new_color]
							P.pixel.icon = P.icon
					Painter.old_color = null
			else
				var/left = findtext(params, ";left=1")
				if(left)
					if(Painter.current_tool == "dropper")
						Painter.current_tool = Painter.previous_tool
						Painter.previous_tool = "dropper"
						for(var/obj/window_button/tool/T in Painter.Paint.contents)
							if(T.icon_state == Painter.current_tool) T.Update(1)
						Painter.Dropper.Button.Update(0)
				else
					Painter.SC.name = Painter.PC.rgb
					Painter.SC.icon -= "#FFFFFF"
					Painter.SC.icon += Painter.PC.rgb
					Painter.SC.rgb = Painter.PC.rgb
					if(Painter.current_tool == "dropper")
						Painter.current_tool = Painter.previous_tool
						Painter.previous_tool = "dropper"
						for(var/obj/window_button/tool/T in Painter.Paint.contents)
							if(T.icon_state == Painter.current_tool) T.Update(1)
						Painter.Dropper.Button.Update(0)

		DblDown(obj/pallete/Ref, params)
			var/mob/chatter/M = Painter.Owner
			M.CV.Display("primary")

SecondaryColor
	var/obj/window_button/Button
	var/Painter/Painter

	New(Painter/P)
		if(!P) return
		..()
		Painter = P
		Button = Painter.SC

	proc
		Down(obj/pallete/Ref, params)
			if(Painter.current_tool == "swap")
				if(!Painter.old_color)
					Painter.old_color = Ref.rgb
				else
					Painter.new_color = Ref.rgb
					for(var/obj/pixel/P in Painter.Paint.contents)
						if(P.rgb == Painter.old_color)
							P.name = Painter.new_color
							P.rgb = Painter.new_color
							P.icon = PaintMan.icon_cache[Painter.new_color]
							P.pixel.icon = P.icon
					Painter.old_color = null
			else
				var/left = findtext(params, ";left=1")
				if(left)
					Painter.PC.name = Ref.rgb
					Painter.PC.icon -= "#FFFFFF"
					Painter.PC.icon += Ref.rgb
					Painter.PC.rgb = Ref.rgb
					if(Painter.current_tool == "dropper")
						Painter.current_tool = Painter.previous_tool
						Painter.previous_tool = "dropper"
						for(var/obj/window_button/tool/T in Painter.Paint.contents)
							if(T.icon_state == Painter.current_tool) T.Update(1)
						Painter.Dropper.Button.Update(0)
				else
					if(Painter.current_tool == "dropper")
						for(var/obj/window_button/tool/T in Painter.Paint.contents)
							if(T.icon_state == Painter.current_tool) T.Update(1)
						Painter.current_tool = Painter.previous_tool
						Painter.previous_tool = "dropper"
						Painter.Dropper.Button.Update(0)

		DblDown(obj/pallete/Ref, params)
			var/mob/chatter/M = Painter.Owner
			M.CV.Display("secondary")
