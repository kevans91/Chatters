
turf
	window
		name = ""
		icon = './resources/icons/paint/window.dmi'

	paint_title
		name = ""
		icon = './resources/icons/paint/paint.dmi'


obj
	window_button
		icon = './resources/icons/paint/paint.dmi'
		icon_state = "button"
		var/obj/window_button/face
		var/PaintView/PV
		mouse_over_pointer = MOUSE_HAND_POINTER

		MouseDown()
			if(!(type in typesof(/obj/window_button) - /obj/window_button))
				face.MouseDown()

		proc
			Initialize(PaintView/P)
				if(!P) return
				..()
				PV = P
				for(var/obj/window_button/B in src.loc)
					if(B == src) continue
					face = B
					if(!(type in typesof(/obj/window_button) - /obj/window_button))
						src.name = face.name
					break

			Update(state)
				if(state)
					if(type in typesof(/obj/window_button) - /obj/window_button)
						src.pixel_y = -1
						face.icon_state = "clicked"
					else
						src.icon_state = "clicked"
						face.pixel_y = -1
				else
					if(type in typesof(/obj/window_button) - /obj/window_button)
						src.pixel_y = 0
						face.icon_state = "button"
					else
						src.icon_state = "button"
						face.pixel_y = 0

		tool
			MouseDown()
				for(var/obj/window_button/tool/T in PV.contents)
					if(T == src) Update(1)
					else T.Update(0)
				PV.owner.Painter.previous_tool = PV.owner.Painter.current_tool
				PV.owner.Painter.current_tool = icon_state

			select
				name = "Select"
				icon_state = "select"

				Initialize()
					..()
					PV.owner.Painter.Select = new()
					PV.owner.Painter.Select.Button = src
					PV.owner.Painter.Select.Painter = PV.owner.Painter
					PV.owner.Painter.tools = listOpen(PV.owner.Painter.tools)
					PV.owner.Painter.tools += PV.owner.Painter.Select

			arrow
				name = "Arrow"
				icon_state = "arrow"

				Initialize()
					..()
					PV.owner.Painter.Arrow = new()
					PV.owner.Painter.Arrow.Button = src
					PV.owner.Painter.Arrow.Painter = PV.owner.Painter
					PV.owner.Painter.tools = listOpen(PV.owner.Painter.tools)
					PV.owner.Painter.tools += PV.owner.Painter.Arrow

			pencil
				name = "Pencil"
				icon_state = "pencil"

				Initialize()
					..()
					PV.owner.Painter.Pencil = new()
					PV.owner.Painter.Pencil.Button = src
					PV.owner.Painter.Pencil.Painter = PV.owner.Painter
					PV.owner.Painter.tools = listOpen(PV.owner.Painter.tools)
					PV.owner.Painter.tools += PV.owner.Painter.Pencil

			eraser
				name = "Eraser"
				icon_state = "eraser"

				Initialize()
					..()
					PV.owner.Painter.Eraser = new()
					PV.owner.Painter.Eraser.Button = src
					PV.owner.Painter.Eraser.Painter = PV.owner.Painter
					PV.owner.Painter.tools = listOpen(PV.owner.Painter.tools)
					PV.owner.Painter.tools += PV.owner.Painter.Eraser

			bucket
				name = "Flood Bucket"
				icon_state = "bucket"

				Initialize()
					..()
					PV.owner.Painter.Bucket = new()
					PV.owner.Painter.Bucket.Button = src
					PV.owner.Painter.Bucket.Painter = PV.owner.Painter
					PV.owner.Painter.tools = listOpen(PV.owner.Painter.tools)
					PV.owner.Painter.tools += PV.owner.Painter.Bucket

			dropper
				name = "Eye Dropper"
				icon_state = "dropper"

				Initialize()
					..()
					PV.owner.Painter.Dropper = new()
					PV.owner.Painter.Dropper.Button = src
					PV.owner.Painter.Dropper.Painter = PV.owner.Painter
					PV.owner.Painter.tools = listOpen(PV.owner.Painter.tools)
					PV.owner.Painter.tools += PV.owner.Painter.Dropper

			swap
				name = "Swap Colors"
				icon_state = "swap"

				Initialize()
					..()
					PV.owner.Painter.Swap = new()
					PV.owner.Painter.Swap.Button = src
					PV.owner.Painter.Swap.Painter = PV.owner.Painter
					PV.owner.Painter.tools = listOpen(PV.owner.Painter.tools)
					PV.owner.Painter.tools += PV.owner.Painter.Swap

			line
				name = "Line"
				icon_state = "line"

				Initialize()
					..()
					PV.owner.Painter.Line = new()
					PV.owner.Painter.Line.Button = src
					PV.owner.Painter.Line.Painter = PV.owner.Painter
					PV.owner.Painter.tools = listOpen(PV.owner.Painter.tools)
					PV.owner.Painter.tools += PV.owner.Painter.Line

			rect
				name = "Rectangle"
				icon_state = "rect"

				Initialize()
					..()
					PV.owner.Painter.Rect = new()
					PV.owner.Painter.Rect.Button = src
					PV.owner.Painter.Rect.Painter = PV.owner.Painter
					PV.owner.Painter.tools = listOpen(PV.owner.Painter.tools)
					PV.owner.Painter.tools += PV.owner.Painter.Rect

			frect
				name = "Filled Rectangle"
				icon_state = "frect"

				Initialize()
					..()
					PV.owner.Painter.fRect = new()
					PV.owner.Painter.fRect.Button = src
					PV.owner.Painter.fRect.Painter = PV.owner.Painter
					PV.owner.Painter.tools = listOpen(PV.owner.Painter.tools)
					PV.owner.Painter.tools += PV.owner.Painter.fRect

			oval
				name = "Oval"
				icon_state = "oval"

				Initialize()
					..()
					PV.owner.Painter.Oval = new()
					PV.owner.Painter.Oval.Button = src
					PV.owner.Painter.Oval.Painter = PV.owner.Painter
					PV.owner.Painter.tools = listOpen(PV.owner.Painter.tools)
					PV.owner.Painter.tools += PV.owner.Painter.Oval

			foval
				name = "Filled Oval"
				icon_state = "foval"

				Initialize()
					..()
					PV.owner.Painter.fOval = new()
					PV.owner.Painter.fOval.Button = src
					PV.owner.Painter.fOval.Painter = PV.owner.Painter
					PV.owner.Painter.tools = listOpen(PV.owner.Painter.tools)
					PV.owner.Painter.tools += PV.owner.Painter.fOval

		toggle
			MouseDown()
				if(pixel_y == 0)
					for(var/turf/canvas/C in block(locate(3,3,1),locate(10,10,1)))
						C.overlays += new/obj/grid()
					Update(1)
				else
					for(var/turf/canvas/C in block(locate(3,3,1),locate(10,10,1)))
						C.overlays.len = null
					Update(0)

			grid
				name = "Toggle Grid"
				icon_state = "grid"

				Initialize()
					..()
					pixel_x -= 32
					face.pixel_x  -= 32

		push
			MouseDown()
				Update(1)
				spawn(3) Update(0)

			left
				name = "Shift Left"
				icon_state = "left"

				MouseDown()
					..()
					var/list/temp[CANVASX][CANVASY]
					var/list/color[CANVASX][CANVASY]
					var/X = 1
					for(var/list/L in PV.grid)
						for(var/Y=1, Y<=CANVASY, Y++)
							var/newX = (X-1 || CANVASX)
							var/obj/pixel/P = L[Y]
							temp[newX][Y] = P.icon
							color[newX][Y] = P.rgb
						X++
					X = 1
					for(var/list/L in temp)
						for(var/Y=1, Y<=CANVASY, Y++)
							var/icon/I = L[Y]
							var/obj/pixel/P = PV.grid[X][Y]
							P.icon = I
							P.pixel.icon = I
							P.rgb = color[X][Y]
						X++
					del(temp)

			right
				name = "Shift Right"
				icon_state = "right"

				Initialize()
					..()
					pixel_x -= 6
					face.pixel_x  -= 6

				MouseDown()
					..()
					var/list/temp[CANVASX][CANVASY]
					var/list/color[CANVASX][CANVASY]
					var/X = 1
					for(var/list/L in PV.grid)
						for(var/Y=1, Y<=CANVASY, Y++)
							var/newX = X+1
							if(newX > 32) newX = 1
							var/obj/pixel/P = L[Y]
							temp[newX][Y] = P.icon
							color[newX][Y] = P.rgb
						X++
					X = 1
					for(var/list/L in temp)
						for(var/Y=1, Y<=CANVASY, Y++)
							var/icon/I = L[Y]
							var/obj/pixel/P = PV.grid[X][Y]
							P.icon = I
							P.pixel.icon = I
							P.rgb = color[X][Y]
						X++
					del(temp)

			up
				name = "Shift Up"
				icon_state = "up"

				Initialize()
					..()
					pixel_x -= 12
					face.pixel_x  -= 12

				MouseDown()
					..()
					var/list/temp[CANVASX][CANVASY]
					var/list/color[CANVASX][CANVASY]
					var/X = 1
					for(var/list/L in PV.grid)
						for(var/Y=1, Y<=CANVASY, Y++)
							var/newY = Y+1
							if(newY > 32) newY = 1
							var/obj/pixel/P = L[Y]
							temp[X][newY] = P.icon
							color[X][newY] = P.rgb
						X++
					X = 1
					for(var/list/L in temp)
						for(var/Y=1, Y<=CANVASY, Y++)
							var/icon/I = L[Y]
							var/obj/pixel/P = PV.grid[X][Y]
							P.icon = I
							P.pixel.icon = I
							P.rgb = color[X][Y]
						X++
					del(temp)

			down
				name = "Shift Down"
				icon_state = "down"

				Initialize()
					..()
					pixel_x -= 18
					face.pixel_x  -= 18

				MouseDown()
					..()
					var/list/temp[CANVASX][CANVASY]
					var/list/color[CANVASX][CANVASY]
					var/X = 1
					for(var/list/L in PV.grid)
						for(var/Y=1, Y<=CANVASY, Y++)
							var/newY = (Y-1 || CANVASY)
							var/obj/pixel/P = L[Y]
							temp[X][newY] = P.icon
							color[X][newY] = P.rgb
						X++
					X = 1
					for(var/list/L in temp)
						for(var/Y=1, Y<=CANVASY, Y++)
							var/icon/I = L[Y]
							var/obj/pixel/P = PV.grid[X][Y]
							P.icon = I
							P.pixel.icon = I
							P.rgb = color[X][Y]
						X++
					del(temp)

			horiz
				name = "Flip Horizontal"
				icon_state = "horiz"

				Initialize()
					..()
					pixel_x -= 16
					face.pixel_x  -= 16

				MouseDown()
					..()
					var/list/temp[CANVASX][CANVASY]
					var/list/color[CANVASX][CANVASY]
					var/X = 1
					for(var/list/L in PV.grid)
						for(var/Y=1, Y<=CANVASY, Y++)
							var/obj/pixel/P = L[Y]
							temp[X][Y] = P.icon
							color[X][Y] = P.rgb
						X++
					X = 1
					temp = invertList(temp)
					color = invertList(color)
					for(var/list/L in temp)
						for(var/Y=1, Y<=CANVASY, Y++)
							var/icon/I = L[Y]
							var/obj/pixel/P = PV.grid[X][Y]
							P.icon = I
							P.pixel.icon = I
							P.rgb = color[X][Y]
						X++
					del(temp)

			vert
				name = "Flip Vertical"
				icon_state = "vert"

				Initialize()
					..()
					pixel_x -= 22
					face.pixel_x  -= 22

				MouseDown()
					..()
					var/list/temp[CANVASX][CANVASY]
					var/list/color[CANVASX][CANVASY]
					var/X = 1
					for(var/list/L in PV.grid)
						for(var/Y=1, Y<=CANVASY, Y++)
							var/obj/pixel/P = L[Y]
							temp[X][Y] = P.icon
							color[X][Y] = P.rgb
						X++
					X = 1
					for(var/list/C in color)
						C = invertList(C)
					for(var/list/L in temp)
						L = invertList(L)
						for(var/Y=1, Y<=CANVASY, Y++)
							var/icon/I = L[Y]
							var/obj/pixel/P = PV.grid[X][Y]
							P.icon = I
							P.pixel.icon = I
							P.rgb = color[X][Y]
						X++
					del(temp)

			neg90
				name = "Rotate -90°"
				icon_state = "-90"

				Initialize()
					..()
					pixel_x -= 28
					face.pixel_x  -= 28

				MouseDown()
					..()
					var/list/temp[CANVASX][CANVASY]
					var/list/color[CANVASX][CANVASY]
					var/X = 1
					for(var/list/L in PV.grid)
						for(var/Y=1, Y<=CANVASY, Y++)
							var/obj/pixel/P = L[Y]
							temp[X][Y] = P.icon
							color[X][Y] = P.rgb
						X++
					X = 1
					for(var/list/C in color)
						C = invertList(C)
					for(var/list/L in temp)
						L = invertList(L)
						for(var/Y=1, Y<=CANVASY, Y++)
							var/icon/I = L[Y]
							var/obj/pixel/P = PV.grid[Y][X]
							P.icon = I
							P.pixel.icon = I
							P.rgb = color[X][Y]
						X++
					del(temp)

			pos90
				name = "Rotate 90°"
				icon_state = "90"

				Initialize()
					..()
					pixel_x -= 34
					face.pixel_x  -= 34

				MouseDown()
					..()
					var/list/temp[CANVASX][CANVASY]
					var/list/color[CANVASX][CANVASY]
					var/X = 1
					for(var/list/L in PV.grid)
						for(var/Y=1, Y<=CANVASY, Y++)
							var/obj/pixel/P = L[Y]
							temp[X][Y] = P.icon
							color[X][Y] = P.rgb
						X++
					X = 1
					temp = invertList(temp)
					color = invertList(color)
					for(var/list/L in temp)
						for(var/Y=1, Y<=CANVASY, Y++)
							var/icon/I = L[Y]
							var/obj/pixel/P = PV.grid[Y][X]
							P.icon = I
							P.pixel.icon = I
							P.rgb = color[X][Y]
						X++
					del(temp)
