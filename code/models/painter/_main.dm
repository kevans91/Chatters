
Painter
	var
		mob/chatter/Owner
		PaintView/Paint
		obj/PrimaryColor/PC
		obj/SecondaryColor/SC
		obj/pallete/Current
		current_tool = "pencil"
		previous_tool
		flooding
		shift
		startX
		startY
		prevX
		prevY
		old_color
		new_color
		Pallete/Pallete
		PrimaryColor/Primary
		SecondaryColor/Secondary
		list
			tools
			current_line
			current_rect
			current_oval
			current_select
			pallete = list(\
				"#FFFFFF","#CCCCCC","#000000","#333333",
				"#999999","#CC0000","#666666","#660000",
				"#CC9900","#CCCC00","#663300","#666600",
				"#99CC00","#00CC00","#336600","#006600",
				"#00CC99","#0099CC","#006633","#003366",
				"#0000CC","#9900CC","#000066","#330066",
				"#CC00CC","#CC0033","#660066","#660033")
		Tools
			select/Select
			arrow/Arrow
			pencil/Pencil
			eraser/Eraser
			bucket/Bucket
			dropper/Dropper
			swap/Swap
			line/Line
			rect/Rect
			frect/fRect
			oval/Oval
			foval/fOval

	Del()
		Owner = null
		del(PC)
		del(SC)
		if(Current) del(Current)
		del(Pallete)
		del(Primary)
		del(Secondary)
		del(Select)
		del(Arrow)
		del(Pencil)
		del(Eraser)
		del(Bucket)
		del(Dropper)
		del(Swap)
		del(Line)
		del(Rect)
		del(fRect)
		del(Oval)
		del(fOval)
		for(var/X in tools) del(X)
		listClose(tools)
		if(current_line)
			current_line.len = null
			listClose(current_line)
		if(current_rect)
			current_rect.len = null
			listClose(current_rect)
		if(current_oval)
			current_oval.len = null
			listClose(current_oval)
		if(current_select)
			current_select.len = null
			listClose(current_select)
		del(Paint)
		..()
