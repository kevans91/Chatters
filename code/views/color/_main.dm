
ColorView
	var
		mob/chatter
			owner
		scope

	New(mob/chatter/o)
		..()
		owner = o
		owner.verbs += /ColorView/proc/PickColor

	Del()
		owner.verbs -= /ColorView/proc/PickColor
		..()


	proc
		PickColor(var/color as text|null)
			set hidden = 1
			winshow(usr, "color_picker", 0)
			if(!color) return
			var/mob/chatter/M = usr
			if(findtext(M.CV.scope, "color")==1)
				var/num = text2num(copytext(M.CV.scope, 6))
				if(!num || (num > M.fade_colors.len)) return
				M.fade_colors[num] = color
				winset(M, "style_colors.color[num]", "background-color='[color]'")
			else switch(M.CV.scope)
				if("name")
					if(M.fade_name == "<font color=[M.name_color]>[M.name]</font>")
						M.fade_name = null
					if(color == "#000000")
						M.name_color = null
					else
						M.name_color = color
					if(!M.fade_name || (M.fade_name == M.name))
						if(M.name_color)
							M.fade_name = "<font color=[M.name_color]>[M.name]</font>"
						else
							M.fade_name = M.name
					winset(M, "style_colors.name_color_button", "background-color='[color]'")
					winset(M, "style_colors.name_color", "text='[color]'")
					M << output("<b>[M.fade_name]</b>", "style_colors.output")
				if("text")
					if(color == "#000000")
						M.text_color = null
					else
						M.text_color = color
					winset(M, "style_colors.text_color_button", "background-color='[color]'")
					winset(M, "style_colors.text_color", "text='[color]'")
				if("background")
					M.background = color
					winset(M, "style_colors.background_button", "background-color='[color]'")
					winset(M, "style_colors.background", "text='[color]'")
				if("primary")
					if(!M.Painter) return
					M.Painter.PC.name = color
					M.Painter.PC.rgb = color
					M.Painter.PC.icon -= "#FFFFFF"
					M.Painter.PC.icon += color
					if(M.Painter.Current)
						M.Painter.Current.name = color
						M.Painter.Current.rgb = color
						M.Painter.Current.icon -= "#FFFFFF"
						M.Painter.Current.icon += color
					var/icon/I = new('./resources/icons/paint/canvas.dmi')
					I.Blend(color, ICON_MULTIPLY)
					PaintMan.icon_cache += color
					PaintMan.icon_cache[color] = I
					M.Painter.Current = null
				if("secondary")
					if(!M.Painter) return
					M.Painter.SC.name = color
					M.Painter.SC.rgb = color
					M.Painter.SC.icon -= "#FFFFFF"
					M.Painter.SC.icon += color
					if(M.Painter.Current)
						M.Painter.Current.name = color
						M.Painter.Current.rgb = color
						M.Painter.Current.icon -= "#FFFFFF"
						M.Painter.Current.icon += color
					var/icon/I = new('./resources/icons/paint/canvas.dmi')
					I.Blend(color, ICON_MULTIPLY)
					PaintMan.icon_cache += color
					PaintMan.icon_cache[color] = I
					M.Painter.Current = null
				if("op_rank")
					call(M, "SetOpRankColor")(color)

		Display(Scope)
			if(!Scope) return
			src.scope = Scope
			winshow(owner, "color_picker", 1)